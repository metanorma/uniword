# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      # Package-level consistency enforcement.
      #
      # Rebuilds content types and relationships for standard parts,
      # preserving non-standard entries from the source document.
      module PackageStructure
        # Relationship types for parts we don't model or serialize.
        UNSUPPORTED_REL_TYPES = Set[
          "http://schemas.microsoft.com/office/2007/relationships/stylesWithEffects",
        ].freeze

        # Rel types that belong in package-level _rels/.rels, not document.xml.rels.
        PACKAGE_LEVEL_REL_TYPES = Set[
          "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument",
          "http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties",
          "http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties",
          "http://schemas.openxmlformats.org/officeDocument/2006/relationships/custom-properties",
        ].freeze

        def reconcile_content_types
          ct = package.content_types
          return unless ct

          ct.defaults = [
            Uniword::ContentTypes::Default.new(
              extension: "rels",
              content_type: "application/vnd.openxmlformats-package.relationships+xml",
            ),
            Uniword::ContentTypes::Default.new(
              extension: "xml",
              content_type: "application/xml",
            ),
          ]

          standard = content_type_overrides_for_present_parts
          standard_parts = standard.to_set(&:part_name)
          non_standard = ct.overrides.reject do |o|
            standard_parts.include?(o.part_name)
          end

          ct.overrides = standard + non_standard
          record_fix(FixCodes::CONTENT_TYPES_ASSEMBLED, "Rebuilt content types for standard parts")
        end

        def reconcile_package_rels
          rels = package.package_rels
          return unless rels

          base = "http://schemas.openxmlformats.org"
          standard_defs = [
            ["rId1",
             "#{base}/officeDocument/2006/relationships/officeDocument",
             "word/document.xml"],
            ["rId2",
             "#{base}/package/2006/relationships/metadata/core-properties",
             "docProps/core.xml"],
            ["rId3",
             "#{base}/officeDocument/2006/relationships/extended-properties",
             "docProps/app.xml"],
          ]

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
          record_fix(FixCodes::RELATIONSHIPS_ASSEMBLED, "Rebuilt package relationships for standard parts")
        end

        def reconcile_document_rels
          rels = package.document_rels
          return unless rels

          base = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"
          defs = [
            ["styles", "styles.xml", package.styles],
            ["settings", "settings.xml", package.settings],
            ["webSettings", "webSettings.xml", package.web_settings],
            ["fontTable", "fontTable.xml", package.font_table],
            ["theme", "theme/theme1.xml", package.theme],
            ["numbering", "numbering.xml", package.numbering],
            ["footnotes", "footnotes.xml", package.footnotes],
            ["endnotes", "endnotes.xml", package.endnotes],
          ]

          standard_targets = defs.filter_map { |_, target, obj| target if obj }.to_set

          # If allocator is present, use it to build rels — preserves existing rIds
          alloc = allocator
          if alloc
            reconcile_document_rels_from_allocator(rels, base, defs, standard_targets, alloc)
          else
            reconcile_document_rels_legacy(rels, base, defs, standard_targets)
          end
        end

        private

        def reconcile_document_rels_from_allocator(rels, base, defs, standard_targets, alloc)
          # Collect standard part rels from allocator
          all_rels = []
          defs.each do |suffix, target, obj|
            next unless obj
            r_id = alloc.rid_for(target: target, type: "#{base}/#{suffix}")
            if r_id
              all_rels << build_rel(r_id, "#{base}/#{suffix}", target)
            else
              all_rels << build_rel(
                alloc.alloc_rid(target: target, type: "#{base}/#{suffix}"),
                "#{base}/#{suffix}", target,
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
          record_fix(FixCodes::RELATIONSHIPS_ASSEMBLED, "Assembled document relationships from allocator")
        end

        def reconcile_document_rels_legacy(rels, base, defs, standard_targets)
          non_standard = rels.relationships.reject do |r|
            standard_targets.include?(r.target) ||
              unsupported_rel_type?(r.type) ||
              package_level_rel?(r.type) ||
              !header_footer_target_present?(r.target)
          end

          all_rels = []
          rid_mapping = {}

          defs.each do |suffix, target, obj|
            next unless obj
            rid = "rId#{all_rels.size + 1}"
            all_rels << build_rel(rid, "#{base}/#{suffix}", target)
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
          record_fix(FixCodes::RELATIONSHIPS_ASSEMBLED, "Rebuilt document relationships with sequential rIds")
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

        # Check if a header/footer rel target corresponds to a serialized part.
        # Headers/footers may be in two places:
        #   - document.headers / document.footers (single-section hash)
        #   - document.header_footer_parts (multi-section ordered array)
        # Headers/footers are numbered sequentially: header1.xml, header2.xml...
        # If the model has fewer headers/footers than the target index, it's stale.
        def header_footer_target_present?(target)
          if target.start_with?("header") && target.end_with?(".xml")
            num = target[/header(\d+)\.xml/, 1]&.to_i
            hash_count = package.document&.headers&.size || 0
            parts_count = count_parts_matching("header")
            count = [hash_count, parts_count].max
            return num && num <= count
          end
          if target.start_with?("footer") && target.end_with?(".xml")
            num = target[/footer(\d+)\.xml/, 1]&.to_i
            hash_count = package.document&.footers&.size || 0
            parts_count = count_parts_matching("footer")
            count = [hash_count, parts_count].max
            return num && num <= count
          end
          true
        end

        def count_parts_matching(prefix)
          parts = package.document&.header_footer_parts
          return 0 unless parts

          parts.count { |p| p[:target].to_s.start_with?(prefix) }
        end

        def content_type_overrides_for_present_parts
          checks = [
            [package.document, "/word/document.xml",
             "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"],
            [package.styles, "/word/styles.xml",
             "application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"],
            [package.settings, "/word/settings.xml",
             "application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"],
            [package.font_table, "/word/fontTable.xml",
             "application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml"],
            [package.web_settings, "/word/webSettings.xml",
             "application/vnd.openxmlformats-officedocument.wordprocessingml.webSettings+xml"],
            [package.theme, "/word/theme/theme1.xml",
             "application/vnd.openxmlformats-officedocument.theme+xml"],
            [package.core_properties, "/docProps/core.xml",
             "application/vnd.openxmlformats-package.core-properties+xml"],
            [package.app_properties, "/docProps/app.xml",
             "application/vnd.openxmlformats-officedocument.extended-properties+xml"],
            [package.footnotes, "/word/footnotes.xml",
             "application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml"],
            [package.endnotes, "/word/endnotes.xml",
             "application/vnd.openxmlformats-officedocument.wordprocessingml.endnotes+xml"],
            [package.numbering, "/word/numbering.xml",
             "application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml"],
          ]

          checks.filter_map do |obj, part_name, content_type|
            next unless obj

            Uniword::ContentTypes::Override.new(
              part_name: part_name,
              content_type: content_type,
            )
          end
        end
      end
    end
  end
end
