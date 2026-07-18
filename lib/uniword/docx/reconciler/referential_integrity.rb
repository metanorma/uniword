# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      # Cross-part referential integrity enforcement.
      #
      # Verifies and repairs references between document.xml and other
      # package parts. Both the allocator (builder) path and the legacy
      # (template-loaded) path repair by stripping: identical input yields
      # identical referential outcome regardless of path. Unrepairable
      # leftovers are rejected by the write-time PackageIntegrityChecker.
      # - For removable inline refs (notes, hyperlinks, drawings): strip
      # - For structural refs (styles, numbering): strip
      # - For relationship refs (rId): reconcile against actual parts
      # - For relationship targets: strip rels whose target part the
      #   package does not carry (the part is never re-emitted, so the
      #   rel would dangle in the saved package)
      # - For uniqueness constraints: deduplicate with deterministic resolution
      module ReferentialIntegrity
        def reconcile_referential_integrity
          return unless package.document&.body

          reconcile_note_body_references(:footnote)
          reconcile_note_body_references(:endnote)
          reconcile_sect_pr_references
          reconcile_image_references
          reconcile_hyperlink_references
          ensure_para_id_uniqueness
          ensure_rid_uniqueness
          reconcile_relationship_targets

          reconcile_style_references
          reconcile_style_inheritance
          reconcile_numbering_body_references
        end

        private

        # -- Note references (body → footnotes.xml / endnotes.xml) --

        def reconcile_note_body_references(type)
          notes = notes_collection_for(type)
          return unless notes

          entries = note_entries_for(notes, type)
          defined_ids = entries
            .reject { |e| VALID_NOTE_TYPES.include?(e.type) }
            .filter_map(&:id).to_set

          removed = 0

          walk_body_paragraphs(package.document.body) do |para|
            para.runs.reject! do |run|
              ref = note_reference_from_run(run, type)
              next false unless ref&.id
              next false if defined_ids.include?(ref.id)

              removed += 1
              true
            end
          end

          return unless removed.positive?

          record_fix(FixCodes::DANGLING_NOTE_REFERENCE_REMOVED,
                     "Removed #{removed} dangling #{type}note reference(s) in body",
                     part: "word/document.xml")
        end

        # -- Section property references (sectPr → document.xml.rels) --

        # Strip header/footer references whose rId does not resolve.
        # Builder-registered headers/footers are wired into document_rels
        # during Group 1 (wire_builder_headers_footers), so any reference
        # still dangling here has no backing part on either path.
        def reconcile_sect_pr_references
          sect_pr = package.document&.body&.section_properties
          return unless sect_pr

          valid_rids = collect_valid_header_footer_rids

          removed = 0
          [sect_pr.header_references, sect_pr.footer_references].each do |refs|
            next unless refs

            removed += refs.count { |r| r.r_id && !valid_rids.include?(r.r_id) }
            refs.reject! { |r| r.r_id && !valid_rids.include?(r.r_id) }
          end

          return unless removed.positive?

          record_fix(FixCodes::DANGLING_HEADER_FOOTER_REMOVED,
                     "Removed #{removed} dangling header/footer reference(s) from sectPr",
                     part: "word/document.xml")
        end

        def collect_valid_header_footer_rids
          rids = Set.new

          (package.document&.header_footer_parts || []).each do |part|
            rids << part[:r_id] if part[:r_id]
          end

          collect_rels_by_type(rids,
                               "officeDocument/2006/relationships/header",
                               "officeDocument/2006/relationships/footer")

          rids
        end

        # -- Style references (body → styles.xml) --

        def reconcile_style_references
          styles = package.styles
          return unless styles

          defined_ids = styles.styles.to_set(&:id)
          style_names = styles.styles.to_set { |s| s.name&.val }.compact
          removed = 0

          walk_body_paragraphs(package.document.body) do |para|
            removed += reconcile_paragraph_style(para, defined_ids, style_names)
            removed += reconcile_run_styles(para, defined_ids, style_names)
          end

          walk_body_tables(package.document.body) do |tbl|
            tbl_ref = tbl.properties&.style
            next unless tbl_ref&.val
            next if defined_ids.include?(tbl_ref.val)
            next if style_names.include?(tbl_ref.val)

            tbl.properties.style = nil
            removed += 1
          end

          return unless removed.positive?

          record_fix(FixCodes::DANGLING_STYLE_REFERENCE_REMOVED,
                     "Removed #{removed} dangling style reference(s) from body",
                     part: "word/document.xml")
        end

        # -- Style inheritance (styles.xml self-references) --

        def reconcile_style_inheritance
          styles = package.styles
          return unless styles

          defined_ids = styles.styles.to_set(&:id)
          stripped = 0

          styles.styles.each do |style|
            based_on = style.basedOn
            if based_on&.val && !defined_ids.include?(based_on.val)
              style.basedOn = nil
              stripped += 1
            end

            link = style.link
            if link&.val && !defined_ids.include?(link.val)
              style.link = nil
              stripped += 1
            end
          end

          return unless stripped.positive?

          record_fix(FixCodes::DANGLING_BASED_ON_REMOVED,
                     "Removed #{stripped} dangling basedOn/link reference(s) in styles",
                     part: "word/styles.xml")
        end

        # -- Numbering references (body → numbering.xml) --

        def reconcile_numbering_body_references
          numbering = package.numbering
          return unless numbering

          defined_num_ids = numbering.instances.to_set(&:num_id)
          return if defined_num_ids.empty?

          removed = 0

          walk_body_paragraphs(package.document.body) do |para|
            num_pr = para.properties&.numbering_properties
            next unless num_pr

            num_id = numbering_num_id_value(num_pr)
            next unless num_id
            next if num_id.zero?
            next if defined_num_ids.include?(num_id)

            para.properties.numbering_properties = nil
            removed += 1
          end

          return unless removed.positive?

          record_fix(FixCodes::DANGLING_NUMBERING_REMOVED,
                     "Removed #{removed} dangling numbering reference(s) from body",
                     part: "word/document.xml")
        end

        # -- Image references (blip/@r:embed → document.xml.rels) --

        # Remove drawings whose r:embed has no matching image relationship,
        # consistent with the other referential repairs. A drawing is kept
        # when it has no embed references (e.g. shape-only anchors) or at
        # least one embed rId resolves.
        def reconcile_image_references
          rels = package.document_rels
          return unless rels

          valid_rids = rels.relationships.to_set(&:id)
          return if valid_rids.empty?

          removed = 0

          walk_body_paragraphs(package.document.body) do |para|
            (para.runs || []).each do |run|
              next unless run.drawings

              kept = run.drawings.reject do |drawing|
                dangling_drawing?(drawing, valid_rids)
              end
              removed += run.drawings.size - kept.size
              run.drawings = kept
            end
          end

          return unless removed.positive?

          record_fix(FixCodes::DANGLING_DRAWING_REMOVED,
                     "Removed #{removed} drawing(s) with dangling image reference(s)",
                     part: "word/document.xml")
        end

        # A drawing is dangling when it carries embed references and none
        # of them resolves to a relationship in document.xml.rels.
        def dangling_drawing?(drawing, valid_rids)
          rids = drawing_embed_rids(drawing)
          return false if rids.empty?

          rids.none? { |rid| valid_rids.include?(rid) }
        end

        # -- Hyperlink references (hyperlink/@r:id → document.xml.rels) --

        # Repair hyperlink references: dangling rIds are stripped (like
        # other referential repairs); literal URLs placed in r:id by
        # Builder.hyperlink's target= are promoted to proper External
        # relationships so the package stays valid and the link survives.
        def reconcile_hyperlink_references
          rels = package.document_rels
          return unless rels

          valid_rids = rels.relationships.to_set(&:id)
          return if valid_rids.empty?

          removed = 0
          promoted = 0

          walk_body_paragraphs(package.document.body) do |para|
            (para.hyperlinks || []).reject! do |hl|
              next false if hl.anchor
              next false unless hl.id
              next false if valid_rids.include?(hl.id)

              if hl.id.match?(/\ArId\d+\z/i)
                removed += 1
                true
              else
                promote_literal_hyperlink(rels, hl, valid_rids)
                promoted += 1
                false
              end
            end
          end

          if promoted.positive?
            record_fix(FixCodes::HYPERLINK_RELATIONSHIP_CREATED,
                       "Promoted #{promoted} literal hyperlink target(s) " \
                       "to external relationship(s)",
                       part: "word/_rels/document.xml.rels")
          end

          return unless removed.positive?

          record_fix(FixCodes::DANGLING_HYPERLINK_REMOVED,
                     "Removed #{removed} dangling hyperlink reference(s) from body",
                     part: "word/document.xml")
        end

        # Promote a hyperlink whose r:id holds a literal URL to a proper
        # External relationship, repointing the hyperlink at the new rId.
        def promote_literal_hyperlink(rels, hyperlink, valid_rids)
          new_rid = Ooxml::Relationships::PackageRelationships
            .next_available_rid(rels)
          rels.relationships << Ooxml::Relationships::Relationship.new(
            id: new_rid,
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink",
            target: hyperlink.id.to_s,
            target_mode: "External",
          )
          valid_rids << new_rid
          hyperlink.id = new_rid
        end

        # -- Uniqueness constraints --

        def ensure_para_id_uniqueness
          seen = {}
          collisions = 0

          walk_all_paragraphs do |para|
            pid = para.para_id
            next unless pid

            if seen.key?(pid)
              para.para_id = generate_hex_id("collision:#{collisions}")
              collisions += 1
            else
              seen[pid] = true
            end
          end

          return unless collisions.positive?

          record_fix(FixCodes::PARAGRAPH_BACKFILL,
                     "Resolved #{collisions} paraId collision(s)",
                     part: "word/document.xml")
        end

        def ensure_rid_uniqueness
          rels = package.document_rels
          return unless rels

          seen = {}
          duplicates = []

          rels.relationships.each do |rel|
            next unless rel.id

            if seen[rel.id]
              duplicates << rel
            else
              seen[rel.id] = true
            end
          end

          return if duplicates.empty?

          duplicates.each do |rel|
            old_id = rel.id
            rel.id = derive_unique_rid(rels, old_id)
            record_fix(FixCodes::RELATIONSHIPS_ASSEMBLED,
                       "Deduplicated rId #{old_id} → #{rel.id}",
                       part: "word/_rels/document.xml.rels")
          end

          record_fix(FixCodes::RELATIONSHIPS_ASSEMBLED,
                     "Resolved #{duplicates.size} rId collision(s)",
                     part: "word/_rels/document.xml.rels")
        end

        # -- Relationship targets (rels → emitted parts) --

        # Strip relationships whose target part the package does not
        # carry. Group 3 preserves non-standard source rels verbatim,
        # including rels to parts uniword does not model (e.g.
        # docProps/meta.xml); those parts are never re-emitted, so the
        # rel would dangle (OPC-006) in the saved package.
        def reconcile_relationship_targets
          carried = carried_part_paths

          rels_collections.each do |rels, base_dir, part|
            strip_dangling_relationship_targets(rels, base_dir, carried,
                                                part)
          end
        end

        # [rels, base directory, .rels part path] for every relationships
        # part the package serializes.
        def rels_collections
          [
            [package.package_rels, "", "_rels/.rels"],
            [package.document_rels, "word", "word/_rels/document.xml.rels"],
            [package.settings_rels, "word", "word/_rels/settings.xml.rels"],
            [package.theme_rels, "word/theme",
             "word/theme/_rels/theme1.xml.rels"],
            [package.footnotes_rels, "word", "word/_rels/footnotes.xml.rels"],
            [package.endnotes_rels, "word", "word/_rels/endnotes.xml.rels"],
          ]
        end

        def strip_dangling_relationship_targets(rels, base_dir, carried,
                                                part)
          return unless rels&.relationships

          dangling = rels.relationships.select do |rel|
            dangling_relationship_target?(rel, base_dir, carried)
          end
          return if dangling.empty?

          dangling.each { |rel| rels.relationships.delete(rel) }
          record_target_removal(dangling, part)
        end

        def record_target_removal(dangling, part)
          targets = dangling.map { |rel| rel.target.to_s }.join(", ")
          record_fix(FixCodes::DANGLING_RELATIONSHIP_TARGET_REMOVED,
                     "Removed #{dangling.size} relationship(s) to parts " \
                     "not carried by the package: #{targets}",
                     part: part)
        end

        # A relationship dangles when it is internal and its resolved
        # target is not among the parts the save path emits.
        def dangling_relationship_target?(rel, base_dir, carried)
          return false if rel.target_mode.to_s == "External"

          target = rel.target.to_s
          return false if target.empty? || target.start_with?("#")

          !carried.include?(resolve_relationship_target(base_dir, target))
        end

        # Resolve a relationship target to a normalized package path,
        # handling package-absolute (leading slash) targets and "..".
        def resolve_relationship_target(base_dir, target)
          return target[1..] if target.start_with?("/")

          File.expand_path(File.join("/", base_dir, target))[1..]
        end

        # Package paths the save path emits, derived from the model —
        # mirrors serialize_package_parts / inject_* emission.
        def carried_part_paths
          paths = carried_word_parts + carried_docprops_parts
          paths.concat(custom_xml_item_paths)
          paths.concat(document_part_paths)
          paths.to_set
        end

        # [model, package path] pairs for single-instance word/ parts.
        def carried_word_parts
          pairs = core_word_pairs + note_word_pairs
          pairs.filter_map { |model, path| path if model }
        end

        def core_word_pairs
          [
            [package.document, "word/document.xml"],
            [package.styles, "word/styles.xml"],
            [package.numbering, "word/numbering.xml"],
            [package.settings, "word/settings.xml"],
            [package.font_table, "word/fontTable.xml"],
            [package.web_settings, "word/webSettings.xml"],
          ]
        end

        def note_word_pairs
          [
            [package.theme, "word/theme/theme1.xml"],
            [package.footnotes, "word/footnotes.xml"],
            [package.endnotes, "word/endnotes.xml"],
            [package.document&.bibliography_sources, "word/sources.xml"],
          ]
        end

        # [model, package path] pairs for single-instance docProps/ parts.
        def carried_docprops_parts
          pairs = [
            [package.core_properties, "docProps/core.xml"],
            [package.app_properties, "docProps/app.xml"],
            [package.custom_properties, "docProps/custom.xml"],
          ]
          pairs.filter_map { |model, path| path if model }
        end

        def custom_xml_item_paths
          (package.custom_xml_items || []).flat_map do |item|
            paths = ["customXml/item#{item[:index]}.xml"]
            if item[:props_xml]
              paths << "customXml/itemProps#{item[:index]}.xml"
            end
            paths
          end
        end

        # Paths emitted from the document model: media, charts,
        # embeddings, headers and footers (hash and multi-section parts).
        def document_part_paths
          doc = package.document
          return [] unless doc

          media_chart_paths(doc) + header_footer_paths(doc)
        end

        def media_chart_paths(doc)
          paths = [doc.image_parts, doc.chart_parts].compact.flat_map do |parts|
            parts.values.map { |data| "word/#{data[:target]}" }
          end
          paths.concat(embedding_paths)
        end

        def embedding_paths
          (package.embeddings || {}).keys.map { |target| "word/#{target}" }
        end

        def header_footer_paths(doc)
          paths = multi_section_part_paths(doc)
          paths.concat(sequential_part_paths("header", doc.headers&.size))
          paths.concat(sequential_part_paths("footer", doc.footers&.size))
          paths
        end

        def multi_section_part_paths(doc)
          (doc.header_footer_parts || []).map do |part|
            "word/#{part[:target]}"
          end
        end

        def sequential_part_paths(prefix, count)
          1.upto(count || 0).map { |i| "word/#{prefix}#{i}.xml" }
        end

        # -- Traversal helpers --

        def reconcile_paragraph_style(para, defined_ids, style_names)
          style_ref = Array(para.properties&.style).first
          return 0 unless style_ref&.value
          return 0 if defined_ids.include?(style_ref.value)
          return 0 if style_names.include?(style_ref.value)

          para.properties.style = nil
          1
        end

        def reconcile_run_styles(para, defined_ids, style_names)
          removed = 0
          (para.runs || []).each do |run|
            r_style = run.properties&.style
            next unless r_style&.value
            next if defined_ids.include?(r_style.value)
            next if style_names.include?(r_style.value)

            run.properties.style = nil
            removed += 1
          end
          removed
        end

        # Extract rId from the blip chain: drawing → inline/anchor → graphic →
        # graphicData → picture → blipFill → blip → embed
        def drawing_embed_rids(drawing)
          rids = []
          [drawing.inline, drawing.anchor].compact.each do |container|
            blip = container.graphic&.graphic_data&.picture&.blip_fill&.blip
            rids << blip.embed.to_s if blip&.embed
          end
          rids
        end

        def numbering_num_id_value(num_pr)
          val = num_pr.num_id
          return nil unless val

          val.is_a?(Integer) ? val : val.value
        end

        def collect_rels_by_type(rids, *type_fragments)
          return unless package.document_rels

          package.document_rels.relationships.each do |rel|
            t = rel.type.to_s
            rids << rel.id if type_fragments.any? { |frag| t.include?(frag) }
          end
        end

        def derive_unique_rid(relationships, _current_rel)
          Ooxml::Relationships::PackageRelationships.next_available_rid(
            relationships,
          )
        end
      end
    end
  end
end
