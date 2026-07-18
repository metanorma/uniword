# frozen_string_literal: true

module Uniword
  module Docx
    class Reconciler
      # Document body reconciliation.
      #
      # Handles section properties, headers/footers, and their
      # mc:Ignorable and paragraph backfill.
      module Body
        def reconcile_section_properties
          return unless package.document&.body

          body = package.document.body

          unless body.section_properties
            body.section_properties = Wordprocessingml::SectionProperties.new(
              page_size: Wordprocessingml::PageDefaults.default_page_size,
              page_margins: Wordprocessingml::PageDefaults.default_page_margins,
              columns: Wordprocessingml::PageDefaults.default_columns,
              doc_grid: Wordprocessingml::PageDefaults.default_doc_grid,
            )
            record_fix(FixCodes::SECTION_PROPERTIES_DEFAULTED,
                       "Added default section properties with US Letter page size",
                       part: "word/document.xml")
            return
          end

          sect_pr = body.section_properties
          fixed = false
          unless sect_pr.page_size
            sect_pr.page_size = Wordprocessingml::PageDefaults.default_page_size
            fixed = true
          end
          unless sect_pr.page_margins
            sect_pr.page_margins = Wordprocessingml::PageDefaults.default_page_margins
            fixed = true
          end
          unless sect_pr.columns
            sect_pr.columns = Wordprocessingml::PageDefaults.default_columns
            fixed = true
          end
          if fixed
            record_fix(FixCodes::SECTION_PROPERTIES_DEFAULTED,
                       "Filled missing pgSz/pgMar/cols in existing section properties",
                       part: "word/document.xml")
          end
        end

        def reconcile_headers_footers
          parts = package.document&.header_footer_parts
          ignorable = Ooxml::Types::McIgnorable.new(FULL_IGNORABLE)

          parts&.each do |part|
            next unless part.content
            next if part.loaded?

            part.content.mc_ignorable = ignorable
          end

          unless allocator
            backfill_header_footer_paragraphs(parts, generate_rsid)
          end

          wire_header_footer_parts
        end

        private

        # Assign rsid/paraId defaults to header/footer paragraphs
        # (legacy non-allocator path only). Seeds preserve the historic
        # per-kind ("hdr:N"/"ftr:N") and per-store ("hfp:N") schemes so
        # generated IDs stay stable across the unified store.
        def backfill_header_footer_paragraphs(parts, rsid)
          return unless parts

          fresh_counts = Hash.new(0)
          parts.each_with_index do |part, pidx|
            next unless part.content

            if part.loaded?
              backfill_paragraphs(part.content.paragraphs, rsid, "hfp:#{pidx}")
            else
              abbrev = part.kind == :footer ? "ftr" : "hdr"
              idx = fresh_counts[part.kind]
              fresh_counts[part.kind] += 1
              backfill_paragraphs(part.content.paragraphs, rsid,
                                  "#{abbrev}:#{idx}")
            end
          end
        end

        # Wire builder-added (fresh) header/footer parts into
        # document_rels and sectPr during reconciliation — the single
        # wiring implementation. Loaded parts keep the relationships
        # and section references they arrived with.
        def wire_header_footer_parts
          doc = package.document
          return unless doc&.body

          parts = doc.header_footer_parts
          return if parts.nil? || parts.empty?

          rels = package.document_rels
          return unless rels

          wired = false
          parts.each do |part|
            next if part.loaded? || part.target.nil?

            r_id = if allocator
                     allocator.alloc_rid(target: part.target,
                                         type: part.rel_type)
                   else
                     find_or_create_rel(rels, part.rel_type, part.target)
                   end
            part.r_id = r_id
            wire_sect_pr_reference(doc, part.kind, part.type, r_id) if part.type
            wired = true
          end

          return unless wired

          # Clear element_order so header/footer references serialize correctly.
          # Ordered mode only outputs elements in element_order; the template's
          # order may not include newly-added references.
          sect_pr = doc.body.section_properties
          sect_pr.element_order = nil if sect_pr&.element_order
        end

        def find_or_create_rel(rels, rel_type, target)
          existing = rels.relationships.find { |r| r.target == target }
          return existing.id if existing

          r_id = Ooxml::Relationships::PackageRelationships
            .next_available_rid(rels)
          rels.relationships << Ooxml::Relationships::Relationship.new(
            id: r_id, type: rel_type, target: target,
          )
          r_id
        end

        def wire_sect_pr_reference(doc, kind, type, r_id)
          sect_pr = doc.body.section_properties
          return unless sect_pr

          refs = case kind
                 when :header then sect_pr.header_references
                 when :footer then sect_pr.footer_references
                 end
          return unless refs

          existing = refs.find { |r| r.type == type }
          if existing
            existing.r_id = r_id
          else
            ref_class = if kind == :header
                          Wordprocessingml::HeaderReference
                        else
                          Wordprocessingml::FooterReference
                        end
            refs << ref_class.new(type: type, r_id: r_id)
          end
        end

        def reconcile_document_body
          return unless profile
          return unless package.document&.body

          doc = package.document
          set_mc_ignorable(doc, prefixes: FULL_IGNORABLE)

          record_fix(FixCodes::MC_IGNORABLE, "Added mc:Ignorable to document body",
                     part: "word/document.xml")

          body = doc.body
          rsid = generate_rsid

          body.paragraphs.each_with_index do |para, idx|
            strip_empty_runs(para)
            next if allocator

            para.rsid_r ||= rsid
            para.rsid_r_default ||= "00000000"
            para.para_id ||= generate_hex_id(idx)
            para.text_id ||= "77777777"
          end

          unless allocator
            record_fix(FixCodes::PARAGRAPH_BACKFILL,
                       "Assigned rsid and paraId to paragraphs",
                       part: "word/document.xml")
          end

          sect_pr = body.section_properties
          return unless sect_pr

          sect_pr.rsid_r ||= rsid
        end
      end
    end
  end
end
