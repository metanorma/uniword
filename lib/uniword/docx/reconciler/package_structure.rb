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

          # Preserve-first: existing rels keep their position and rId;
          # only genuinely missing standard parts are appended, with
          # rIds allocated by the allocator (seeded from these rels).
          # A later rel whose rId duplicates an already-kept one is
          # dropped — duplicates are impossible by construction.
          kept = []
          seen_ids = Set.new
          rels.relationships.each do |rel|
            next if rel.id && seen_ids.include?(rel.id)

            kept << rel
            seen_ids << rel.id if rel.id
          end

          PACKAGE_REL_PARTS.each do |key|
            defn = Ooxml::PartRegistry.find_by_key(key)
            next if kept.any? { |r| r.target == defn.target }

            kept << build_rel(
              allocator.alloc_rid(target: defn.target, type: defn.rel_type,
                                  scope: :package),
              defn.rel_type, defn.target,
            )
          end

          rels.relationships = kept
          record_fix(FixCodes::RELATIONSHIPS_ASSEMBLED,
                     "Assembled package relationships (preserve-first)",
                     part: "_rels/.rels")
        end

        def reconcile_document_rels
          rels = package.document_rels
          return unless rels

          assemble_document_rels(rels, document_rel_defs)
        end

        private

        # [PartDefinition, package part] pairs for document-level parts
        # that must carry a relationship when present, in emission order.
        def document_rel_defs
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

          sources = package.bibliography_sources ||
            package.document&.bibliography_sources
          if sources
            defs << [Ooxml::PartRegistry.find_by_key(:bibliography), sources]
          end

          defs
        end

        # Preserve-first assembly: existing relationships keep their
        # position and rId (the allocator was seeded from them), new
        # standard parts and new allocator-registered entries (images,
        # hyperlinks, headers/footers added at build time) are appended
        # with freshly allocated ids. No renumbering, ever.
        def assemble_document_rels(rels, defs)
          alloc = allocator
          register_auxiliary_part_rels(alloc)
          kept = kept_existing_relationships(rels, alloc)
          kept_targets = kept.to_set(&:target)

          append_missing_standard_rels(kept, kept_targets, defs, alloc)
          append_allocator_rels(kept, kept_targets, alloc)

          rels.relationships = kept
          record_fix(FixCodes::RELATIONSHIPS_ASSEMBLED,
                     "Assembled document relationships (preserve-first)",
                     part: "word/_rels/document.xml.rels")
        end

        # Existing rels that survive the assembly, in original order:
        # drops unsupported and package-level types and stale
        # header/footer targets; everything else keeps its rId verbatim
        # (or the allocator's reallocated id when seeding resolved a
        # collision for this target+type).
        def kept_existing_relationships(rels, alloc)
          used_ids = Set.new
          rels.relationships.filter_map do |rel|
            next if unsupported_rel_type?(rel.type)
            next if package_level_rel?(rel.type)
            next unless header_footer_target_present?(rel.target)

            rid = alloc.rid_for(target: rel.target, type: rel.type)
            rid = rel.id if rid.nil? || used_ids.include?(rid)
            next if rid && used_ids.include?(rid)

            used_ids << rid if rid
            build_rel(rid, rel.type, rel.target,
                      target_mode: rel.target_mode)
          end
        end

        # Register rels for package-carried parts outside the standard
        # defs: OLE/embedded binaries and chart parts. Loaded packages
        # seeded these already (no-op); programmatically added parts
        # get freshly allocated ids from the allocator.
        def register_auxiliary_part_rels(alloc)
          ole = Ooxml::PartRegistry.find_by_key(:ole_object)
          (package.embeddings&.keys || []).each do |target|
            alloc.alloc_rid(target: target, type: ole.rel_type)
          end

          chart = Ooxml::PartRegistry.find_by_key(:chart)
          (package.document&.chart_parts&.values || []).each do |data|
            next unless data[:target]

            alloc.alloc_rid(target: data[:target], type: chart.rel_type)
          end
        end

        # Append rels for present standard parts that have no
        # relationship yet (fresh or newly added parts).
        def append_missing_standard_rels(kept, kept_targets, defs, alloc)
          defs.each do |defn, obj|
            next unless obj
            next if kept_targets.include?(defn.target)

            kept << build_rel(
              alloc.alloc_rid(target: defn.target, type: defn.rel_type),
              defn.rel_type, defn.target,
            )
            kept_targets << defn.target
          end
        end

        # Append allocator-registered rels not already present —
        # builder-added images, hyperlinks, charts, headers/footers.
        def append_allocator_rels(kept, kept_targets, alloc)
          alloc.all_rels(scope: :document).each do |entry|
            next if kept_targets.include?(entry[:target])
            next if unsupported_rel_type?(entry[:type])
            next if package_level_rel?(entry[:type])
            next unless header_footer_target_present?(entry[:target])

            kept << build_rel(
              entry[:id], entry[:type], entry[:target],
              target_mode: entry[:target_mode],
            )
            kept_targets << entry[:target]
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
