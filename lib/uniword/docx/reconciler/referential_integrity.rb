# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      # Cross-part referential integrity enforcement.
      #
      # Verifies and repairs references between document.xml and other
      # package parts. Each method follows the principle of least surprise:
      # - For removable inline refs (notes): strip dangling silently
      # - For structural refs (styles, numbering): warn and strip
      # - For relationship refs (rId): reconcile against actual parts
      # - For uniqueness constraints: deduplicate with deterministic resolution
      module ReferentialIntegrity
        def reconcile_referential_integrity
          return unless package.document&.body

          if allocator
            validate_builder_references
          else
            repair_all_references
          end

          reconcile_style_references
          reconcile_style_inheritance
          reconcile_numbering_body_references
        end

        private

        # Allocator present: builders produce correct output.
        # Validate builder-constrained references — warn on issues
        # but don't silently strip (indicates a builder bug).
        def validate_builder_references
          validate_note_references(:footnote)
          validate_note_references(:endnote)
          reconcile_image_references
          validate_hyperlink_references
          ensure_para_id_uniqueness
          ensure_rid_uniqueness
          reconcile_sect_pr_references
        end

        # No allocator: legacy repair path for template-loaded content.
        def repair_all_references
          reconcile_note_body_references(:footnote)
          reconcile_note_body_references(:endnote)
          reconcile_sect_pr_references
          reconcile_image_references
          reconcile_hyperlink_references
          ensure_para_id_uniqueness
          ensure_rid_uniqueness
        end

        # Validate that note references in the body match existing notes.
        # Logs warnings but does NOT strip — builder should produce correct refs.
        def validate_note_references(type)
          notes = notes_collection_for(type)
          return unless notes

          entries = note_entries_for(notes, type)
          defined_ids = entries
            .reject { |e| VALID_NOTE_TYPES.include?(e.type) }
            .filter_map(&:id).to_set

          dangling = 0
          walk_body_paragraphs(package.document.body) do |para|
            para.runs.each do |run|
              ref = note_reference_from_run(run, type)
              next unless ref&.id
              next if defined_ids.include?(ref.id)

              dangling += 1
              Uniword.logger&.warn do
                "Dangling #{type}note reference id=#{ref.id} in body — " \
                "builder produced invalid reference"
              end
            end
          end

          return unless dangling.positive?

          record_fix(FixCodes::DANGLING_NOTE_REFERENCE_WARNING,
                     "WARNING: Found #{dangling} dangling #{type}note reference(s) " \
                     "in body (allocator path — builder bug)")
        end

        # Validate that hyperlink references match existing rels.
        # Logs warnings but does NOT strip — builder should register hyperlinks.
        def validate_hyperlink_references
          rels = package.document_rels
          return unless rels

          valid_rids = rels.relationships.to_set(&:id)
          return if valid_rids.empty?

          dangling = 0
          walk_body_paragraphs(package.document.body) do |para|
            (para.hyperlinks || []).each do |hl|
              next if hl.anchor
              next unless hl.id
              next unless hl.id.match?(/\ArId\d+\z/i)
              next if valid_rids.include?(hl.id)

              dangling += 1
              Uniword.logger&.warn do
                "Dangling hyperlink r:id=#{hl.id} in body — " \
                "builder failed to register hyperlink with allocator"
              end
            end
          end

          return unless dangling.positive?

          record_fix(FixCodes::DANGLING_HYPERLINK_WARNING,
                     "WARNING: Found #{dangling} dangling hyperlink reference(s) " \
                     "in body (allocator path — builder bug)")
        end

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
                     "Removed #{removed} dangling #{type}note reference(s) in body")
        end

        # -- Section property references (sectPr → document.xml.rels) --

        def reconcile_sect_pr_references
          sect_pr = package.document&.body&.section_properties
          return unless sect_pr

          valid_rids = collect_valid_header_footer_rids
          return if valid_rids.empty?

          removed = 0
          [sect_pr.header_references, sect_pr.footer_references].each do |refs|
            next unless refs

            removed += refs.count { |r| r.r_id && !valid_rids.include?(r.r_id) }
            refs.reject! { |r| r.r_id && !valid_rids.include?(r.r_id) }
          end

          return unless removed.positive?

          record_fix(FixCodes::DANGLING_HEADER_FOOTER_REMOVED,
                     "Removed #{removed} dangling header/footer reference(s) from sectPr")
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
                     "Removed #{removed} dangling style reference(s) from body")
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
                     "Removed #{stripped} dangling basedOn/link reference(s) in styles")
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
                     "Removed #{removed} dangling numbering reference(s) from body")
        end

        # -- Image references (blip/@r:embed → document.xml.rels) --

        def reconcile_image_references
          rels = package.document_rels
          return unless rels

          valid_rids = rels.relationships.to_set(&:id)
          return if valid_rids.empty?

          dangling = 0

          walk_body_paragraphs(package.document.body) do |para|
            (para.runs || []).each do |run|
              (run.drawings || []).each do |drawing|
                drawing_embed_rids(drawing).each do |rid|
                  next if valid_rids.include?(rid)

                  dangling += 1
                end
              end
            end
          end

          return unless dangling.positive?

          record_fix(FixCodes::DANGLING_DRAWING_REMOVED,
                     "Found #{dangling} drawing(s) with dangling image reference(s)")
        end

        # -- Hyperlink references (hyperlink/@r:id → document.xml.rels) --

        def reconcile_hyperlink_references
          rels = package.document_rels
          return unless rels

          valid_rids = rels.relationships.to_set(&:id)
          return if valid_rids.empty?

          removed = 0

          walk_body_paragraphs(package.document.body) do |para|
            (para.hyperlinks || []).reject! do |hl|
              next false if hl.anchor
              next false unless hl.id
              next false unless hl.id.match?(/\ArId\d+\z/i)
              next false if valid_rids.include?(hl.id)

              removed += 1
              true
            end
          end

          return unless removed.positive?

          record_fix(FixCodes::DANGLING_HYPERLINK_REMOVED,
                     "Removed #{removed} dangling hyperlink reference(s) from body")
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
                     "Resolved #{collisions} paraId collision(s)")
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
                       "Deduplicated rId #{old_id} → #{rel.id}")
          end

          record_fix(FixCodes::RELATIONSHIPS_ASSEMBLED, "Resolved #{duplicates.size} rId collision(s)")
        end

        # -- Traversal helpers --

        def reconcile_paragraph_style(para, defined_ids, style_names)
          style_ref = para.properties&.style
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
