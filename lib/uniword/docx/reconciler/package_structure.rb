# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      # Package-level consistency enforcement.
      #
      # Rebuilds content types and relationships for standard parts,
      # preserving non-standard entries from the source document.
      # All part metadata (paths, content types, rel types) comes from
      # Ooxml::PartRegistry; this module only declares which parts go
      # where, in which order.
      module PackageStructure
        # Relationship types for parts we don't model or serialize.
        # Exception: stylesWithEffects is a Microsoft extension never
        # written by uniword, so it is not in Ooxml::PartRegistry.
        UNSUPPORTED_REL_TYPES = Set[
          "http://schemas.microsoft.com/office/2007/relationships/stylesWithEffects",
        ].freeze

        # Rel types that belong in package-level _rels/.rels, not document.xml.rels.
        PACKAGE_LEVEL_REL_TYPES =
          Ooxml::PartRegistry.package_rel_types.to_set.freeze

        # Standard package-level parts, in _rels/.rels emission order.
        PACKAGE_REL_PARTS = %i[document core_properties app_properties].freeze

        def reconcile_content_types
          ct = package.content_types
          return unless ct

          ct.defaults = %i[rels xml].map do |key|
            defn = Ooxml::PartRegistry.find_by_key(key)
            Uniword::ContentTypes::Default.new(
              extension: defn.extension,
              content_type: defn.content_type,
            )
          end

          standard = content_type_overrides_for_present_parts
          standard_parts = standard.to_set(&:part_name)
          non_standard = ct.overrides.reject do |o|
            standard_parts.include?(o.part_name)
          end

          ct.overrides = standard + non_standard
          record_fix(FixCodes::CONTENT_TYPES_ASSEMBLED,
                     "Rebuilt content types for standard parts",
                     part: "[Content_Types].xml")
        end

        def reconcile_package_rels
          rels = package.package_rels
          return unless rels

          standard_defs = PACKAGE_REL_PARTS.each_with_index.map do |key, idx|
            defn = Ooxml::PartRegistry.find_by_key(key)
            ["rId#{idx + 1}", defn.rel_type, defn.target]
          end

          standard_targets = standard_defs.to_set { |_, _, t| t }
          standard_rids = standard_defs.to_set { |rid, _, _| rid }
          non_standard = rels.relationships.reject do |r|
            standard_targets.include?(r.target) || standard_rids.include?(r.id)
          end

          existing_by_target = rels.relationships.to_h { |r| [r.target, r] }
          standard = standard_defs.map do |rid, type, target|
            existing = existing_by_target[target]
            build_rel(existing ? existing.id : rid, type, target)
          end

          rels.relationships = standard + non_standard
          record_fix(FixCodes::RELATIONSHIPS_ASSEMBLED,
                     "Rebuilt package relationships for standard parts",
                     part: "_rels/.rels")
        end

        def reconcile_document_rels
          rels = package.document_rels
          return unless rels

          defs = [
            [Ooxml::PartRegistry.find_by_key(:styles), package.styles],
            [Ooxml::PartRegistry.find_by_key(:settings), package.settings],
            [Ooxml::PartRegistry.find_by_key(:web_settings),
             package.web_settings],
            [Ooxml::PartRegistry.find_by_key(:font_table),
             package.font_table],
            [Ooxml::PartRegistry.find_by_key(:theme), package.theme],
            [Ooxml::PartRegistry.find_by_key(:numbering), package.numbering],
            [Ooxml::PartRegistry.find_by_key(:footnotes), package.footnotes],
            [Ooxml::PartRegistry.find_by_key(:endnotes), package.endnotes],
          ]

          standard_targets = defs.filter_map do |defn, obj|
            defn.target if obj
          end.to_set

          # If allocator is present, use it to build rels — preserves existing rIds
          alloc = allocator
          if alloc
            reconcile_document_rels_from_allocator(rels, defs, standard_targets, alloc)
          else
            register_legacy_image_relationships(rels)
            reconcile_document_rels_legacy(rels, defs, standard_targets)
          end
        end

        private

        # Register image parts as relationships before the legacy rebuild.
        # Builder-assigned image rIds may collide with standard part rIds;
        # registering them up front lets the legacy renumbering (and blip
        # reference remapping) keep every rId unique.
        def register_legacy_image_relationships(rels)
          images = package.document&.image_parts
          return unless images

          image_rel_type = Ooxml::PartRegistry.find_by_key(:image).rel_type
          images.each do |r_id, image_data|
            next if rels.relationships.any? { |r| r.target == image_data[:target] }

            rels.relationships << build_rel(r_id, image_rel_type,
                                            image_data[:target])
          end
        end

        def reconcile_document_rels_from_allocator(rels, defs, standard_targets, alloc)
          # Collect standard part rels from allocator
          all_rels = []
          defs.each do |defn, obj|
            next unless obj
            r_id = alloc.rid_for(target: defn.target, type: defn.rel_type)
            if r_id
              all_rels << build_rel(r_id, defn.rel_type, defn.target)
            else
              all_rels << build_rel(
                alloc.alloc_rid(target: defn.target, type: defn.rel_type),
                defn.rel_type, defn.target,
              )
            end
          end

          # Add allocator-managed rels (images, headers, footers, hyperlinks)
          alloc.all_rels.each do |entry|
            next if standard_targets.include?(entry[:target])
            next if all_rels.any? { |r| r.target == entry[:target] }
            next if unsupported_rel_type?(entry[:type])
            next if package_level_rel?(entry[:type])
            next unless header_footer_target_present?(entry[:target])

            all_rels << build_rel(
              entry[:id], entry[:type], entry[:target],
              target_mode: entry[:target_mode],
            )
          end

          # Preserve non-standard rels not managed by allocator
          existing_targets = all_rels.to_set(&:target)
          non_standard = rels.relationships.reject do |r|
            existing_targets.include?(r.target) ||
              standard_targets.include?(r.target) ||
              unsupported_rel_type?(r.type) ||
              package_level_rel?(r.type) ||
              !header_footer_target_present?(r.target)
          end

          rels.relationships = all_rels + non_standard
          record_fix(FixCodes::RELATIONSHIPS_ASSEMBLED,
                     "Assembled document relationships from allocator",
                     part: "word/_rels/document.xml.rels")
        end

        def reconcile_document_rels_legacy(rels, defs, standard_targets)
          non_standard = rels.relationships.reject do |r|
            standard_targets.include?(r.target) ||
              unsupported_rel_type?(r.type) ||
              package_level_rel?(r.type) ||
              !header_footer_target_present?(r.target)
          end

          all_rels = []
          rid_mapping = {}

          defs.each do |defn, obj|
            next unless obj
            rid = "rId#{all_rels.size + 1}"
            all_rels << build_rel(rid, defn.rel_type, defn.target)
          end

          non_standard.each do |rel|
            old_rid = rel.id
            new_rid = "rId#{all_rels.size + 1}"
            rid_mapping[old_rid] = new_rid if old_rid != new_rid
            all_rels << build_rel(new_rid, rel.type, rel.target,
                                  target_mode: rel.target_mode)
          end

          rels.relationships = all_rels
          update_sect_pr_rid_references(rid_mapping) unless rid_mapping.empty?
          update_blip_embed_references(rid_mapping) unless rid_mapping.empty?
          update_hyperlink_rid_references(rid_mapping) unless rid_mapping.empty?
          record_fix(FixCodes::RELATIONSHIPS_ASSEMBLED,
                     "Rebuilt document relationships with sequential rIds",
                     part: "word/_rels/document.xml.rels")
        end

        def update_sect_pr_rid_references(mapping)
          sect_pr = package.document&.body&.section_properties
          return unless sect_pr

          [sect_pr.header_references, sect_pr.footer_references].each do |refs|
            next unless refs

            refs.each do |ref|
              new_rid = mapping[ref.r_id]
              ref.r_id = new_rid if new_rid
            end
          end
        end

        def update_blip_embed_references(mapping)
          paragraphs = package.document&.body&.paragraphs
          return unless paragraphs

          paragraphs.each do |para|
            next unless para.runs

            para.runs.each do |run|
              next unless run.drawings

              run.drawings.each do |drawing|
                update_drawing_blip(drawing, mapping)
              end
            end
          end
        end

        def update_drawing_blip(drawing, mapping)
          graphic = drawing.inline&.graphic || drawing.anchor&.graphic
          return unless graphic

          picture = graphic.graphic_data&.picture
          return unless picture

          blip = picture.blip_fill&.blip
          return unless blip&.embed

          new_rid = mapping[blip.embed.to_s]
          blip.embed = new_rid if new_rid
        end

        def update_hyperlink_rid_references(mapping)
          body = package.document&.body
          return unless body

          walk_body_paragraphs(body) do |para|
            (para.hyperlinks || []).each do |hl|
              next unless hl.id
              new_rid = mapping[hl.id.to_s]
              hl.id = new_rid if new_rid
            end
          end
        end

        def unsupported_rel_type?(type)
          UNSUPPORTED_REL_TYPES.include?(type.to_s)
        end

        def package_level_rel?(type)
          PACKAGE_LEVEL_REL_TYPES.include?(type.to_s)
        end

        # Check if a header/footer rel target corresponds to a part the
        # package will emit. All header/footer parts live in the unified
        # store (document.header_footer_parts), whether loaded from the
        # source package or added programmatically; a rel whose target
        # is not in the store points at a part that will not be
        # serialized and must be treated as stale.
        def header_footer_target_present?(target)
          header_like = target.start_with?("header") || target.start_with?("footer")
          if header_like && target.end_with?(".xml")
            parts = package.document&.header_footer_parts
            return false unless parts

            return parts.targets.include?(target)
          end
          true
        end

        # [registry key, package part] pairs in content-types emission
        # order; overrides are derived from Ooxml::PartRegistry.
        def content_type_overrides_for_present_parts
          checks = [
            [:document, package.document],
            [:styles, package.styles],
            [:settings, package.settings],
            [:font_table, package.font_table],
            [:web_settings, package.web_settings],
            [:theme, package.theme],
            [:core_properties, package.core_properties],
            [:app_properties, package.app_properties],
            [:footnotes, package.footnotes],
            [:endnotes, package.endnotes],
            [:numbering, package.numbering],
          ]

          checks.filter_map do |key, obj|
            next unless obj

            defn = Ooxml::PartRegistry.find_by_key(key)
            Uniword::ContentTypes::Override.new(
              part_name: defn.part_name,
              content_type: defn.content_type,
            )
          end
        end
      end
    end
  end
end
