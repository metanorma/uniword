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
                       "Added default section properties with US Letter page size")
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
                       "Filled missing pgSz/pgMar/cols in existing section properties")
          end
        end

        def reconcile_headers_footers
          ignorable = Ooxml::Types::McIgnorable.new(FULL_IGNORABLE)
          set_header_footer_ignorable(package.document&.headers, ignorable)
          set_header_footer_ignorable(package.document&.footers, ignorable)

          unless allocator
            rsid = generate_rsid
            backfill_header_footer_parts(package.document&.headers, rsid, "hdr")
            backfill_header_footer_parts(package.document&.footers, rsid, "ftr")

            parts = package.document&.header_footer_parts
            parts&.each_with_index do |part, pidx|
              backfill_paragraphs(part[:content].paragraphs, rsid, "hfp:#{pidx}")
            end
          end

          wire_builder_headers_footers
        end

        private

        def set_header_footer_ignorable(parts, ignorable)
          return unless parts

          parts.each_value { |part| part.mc_ignorable = ignorable }
        end

        def backfill_header_footer_parts(parts, rsid, prefix)
          return unless parts

          parts.each_with_index do |(_, part), pidx|
            backfill_paragraphs(part.paragraphs, rsid, "#{prefix}:#{pidx}")
          end
        end

        HEADER_REL_TYPE = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/header"
        FOOTER_REL_TYPE = "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer"

        # Wire builder-path headers/footers into document_rels and sectPr
        # during reconciliation so referential integrity checks see valid rIds.
        def wire_builder_headers_footers
          doc = package.document
          return unless doc&.body
          return unless doc.headers || doc.footers

          rels = package.document_rels
          return unless rels

          counter = 0
          wire_parts_to_rels(doc.headers, rels, HEADER_REL_TYPE,
                             "header", counter) do |type, r_id|
            wire_sect_pr_reference(doc, :header, type, r_id)
          end

          counter = 0
          wire_parts_to_rels(doc.footers, rels, FOOTER_REL_TYPE,
                             "footer", counter) do |type, r_id|
            wire_sect_pr_reference(doc, :footer, type, r_id)
          end

          # Clear element_order so header/footer references serialize correctly.
          # Ordered mode only outputs elements in element_order; the template's
          # order may not include newly-added references.
          sect_pr = doc.body.section_properties
          sect_pr.element_order = nil if sect_pr&.element_order
        end

        def wire_parts_to_rels(parts, rels, rel_type, file_prefix, counter)
          return unless parts && !parts.empty?

          parts.each_key do |type|
            counter += 1
            target = "#{file_prefix}#{counter}.xml"
            r_id = if allocator
                     allocator.alloc_rid(target: target, type: rel_type)
                   else
                     find_or_create_rel(rels, rel_type, target)
                   end
            yield type, r_id
          end
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

          record_fix(FixCodes::MC_IGNORABLE, "Added mc:Ignorable to document body")

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

          record_fix(FixCodes::PARAGRAPH_BACKFILL, "Assigned rsid and paraId to paragraphs") unless allocator

          sect_pr = body.section_properties
          return unless sect_pr

          sect_pr.rsid_r ||= rsid
        end
      end
    end
  end
end
