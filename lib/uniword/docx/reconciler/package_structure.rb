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
        # These are legacy/transitional OOXML parts (Word 2010 Transitional)
        # whose relationships must be dropped to avoid dangling references.
        UNSUPPORTED_REL_TYPES = Set[
          "http://schemas.microsoft.com/office/2007/relationships/stylesWithEffects",
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
          record_fix("R7", "Rebuilt content types for standard parts")
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
          record_fix("R6", "Rebuilt package relationships for standard parts")
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
          non_standard = rels.relationships.reject do |r|
            standard_targets.include?(r.target) || unsupported_rel_type?(r.type)
          end

          # Build all relationships with sequential rIds
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
          record_fix("R6", "Rebuilt document relationships with sequential rIds")
        end

        private

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

        def unsupported_rel_type?(type)
          UNSUPPORTED_REL_TYPES.include?(type.to_s)
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
