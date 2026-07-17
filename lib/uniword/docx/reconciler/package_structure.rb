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

          # With an allocator, rels are rebuilt from its entries.
          # Package.from_file and the template builders carry one.
          # Uniword.load does not — it drops Package#allocator at the
          # DocumentRoot boundary — so ordinary load/save takes the path
          # below, which keeps the rIds the document arrived with; only
          # missing or colliding ones are allocated again.
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

          existing_by_target = rels.relationships.to_h { |r| [r.target, r] }
          used_rids = rels.relationships.to_set(&:id)

          standard = defs.filter_map do |suffix, target, obj|
            next unless obj

            existing = existing_by_target[target]
            rid = existing&.id || allocate_free_rid(used_rids)
            build_rel(rid, "#{base}/#{suffix}", target)
          end

          deduped = reassign_colliding_rids(non_standard, standard, used_rids)
          rels.relationships = standard + deduped
          record_fix(FixCodes::RELATIONSHIPS_ASSEMBLED,
                     "Assembled document rels, preserving existing rIds")
        end

        # Every rel needs a unique id. A malformed source can reuse one —
        # across a standard part and a non-standard rel, or between two
        # non-standard rels — or omit it entirely. Such a rel is given a
        # fresh id, and its references move with it; otherwise they keep
        # resolving to whichever rel kept the id. Only these are touched, so
        # well-formed input is preserved verbatim.
        #
        # Mappings are kept per reference kind. When two rels shared an id,
        # only the reference of the reassigned rel's own kind belongs to it —
        # a hyperlink reference follows the hyperlink rel, never the header
        # rel that kept the id.
        def reassign_colliding_rids(non_standard, standard, used_rids)
          claimed = standard.to_set(&:id)
          mappings = Hash.new { |h, kind| h[kind] = {} }

          reassigned = non_standard.map do |rel|
            next rel if rel.id && claimed.add?(rel.id)

            new_id = allocate_free_rid(used_rids)
            claimed << new_id
            kind = reference_kind(rel.type)
            mappings[kind][rel.id] = new_id if rel.id && kind
            record_fix(FixCodes::RELATIONSHIPS_ASSEMBLED,
                       "Reassigned rId #{rel.id.inspect} → #{new_id}")
            build_rel(new_id, rel.type, rel.target,
                      target_mode: rel.target_mode)
          end

          apply_rid_mappings(mappings)
          reassigned
        end

        # Walks the document only for kinds that actually moved — the common
        # case reassigns nothing and walks nothing.
        def apply_rid_mappings(mappings)
          mappings.each do |kind, mapping|
            next if mapping.empty?

            case kind
            when :sect_pr then update_sect_pr_rid_references(mapping)
            when :blip then update_blip_embed_references(mapping)
            when :hyperlink then update_hyperlink_rid_references(mapping)
            end
          end
        end

        # Which document reference names a rel of this type, or nil when
        # nothing in document.xml points at it by id.
        def reference_kind(type)
          case type.to_s
          when IdAllocator::HEADER_REL_TYPE, IdAllocator::FOOTER_REL_TYPE
            :sect_pr
          when IdAllocator::IMAGE_REL_TYPE then :blip
          when IdAllocator::HYPERLINK_REL_TYPE then :hyperlink
          end
        end

        # Next numeric rId above the current maximum, so it cannot collide
        # with a preserved id. Unlike PackageRelationships.next_available_rid,
        # this tracks ids across calls, because the rebuilt list is not
        # committed until every id has been chosen.
        def allocate_free_rid(used_rids)
          max = used_rids.filter_map do |id|
            id&.[](/\ArId(\d+)\z/, 1)&.to_i
          end.max || 0
          rid = "rId#{max + 1}"
          used_rids << rid
          rid
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
