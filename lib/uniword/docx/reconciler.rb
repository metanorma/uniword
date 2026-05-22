# frozen_string_literal: true

require "yaml"
require "digest"

module Uniword
  module Docx
    # Reconciles DOCX-level invariants before serialization.
    #
    # Ensures that the document's model state is internally consistent so that
    # the serialized output is always a valid DOCX file. Called from
    # Docx::Package#to_zip_content before the serialization phase.
    #
    # This is not an extension point -- it enforces built-in invariants.
    # For customizable validation, use Uniword::Validation::Rules instead.
    # For user-defined requirements, use Docx::Requirement (future).
    class Reconciler
      CONFIG_DIR = File.join(__dir__, "../../../config")

      # All w1x/w16x extension namespace prefixes declared by namespace_scope
      # on wordprocessingml parts. These MUST be listed in mc:Ignorable so
      # Word doesn't reject them as unknown extensions.
      IGNORABLE_PREFIXES = %w[
        w14 w15 w16se w16cid w16 w16cex w16sdtdh w16sdtfl w16du
      ].freeze

      # Extension prefixes used in document.xml (adds wp14 for drawing)
      IGNORABLE_PREFIXES_DOCUMENT = (IGNORABLE_PREFIXES + %w[wp14]).freeze

      def initialize(package, profile: nil)
        @package = package
        @profile = profile
        @applied_fixes = []
      end

      def reconcile
        # Group 1: Document body (always)
        reconcile_section_properties
        reconcile_footnotes
        reconcile_endnotes
        reconcile_note_references
        reconcile_headers_footers
        reconcile_tables
        repair_theme
        reconcile_referential_integrity

        # Group 2: Support parts (profile-dependent)
        if @profile
          reconcile_theme
          reconcile_settings
          reconcile_font_table
          reconcile_styles
          reconcile_numbering
          reconcile_web_settings
          reconcile_app_properties
          reconcile_core_properties
          reconcile_document_body
        end

        # Clear stored namespace plans so declare: :always scopes take effect
        clear_stored_namespace_plans

        # Group 3: Package consistency (always)
        reconcile_content_types
        reconcile_package_rels
        reconcile_document_rels
      end

      # Audit trail of fixes applied during reconciliation.
      # Each entry is { validity_rule:, message:, timestamp: }.
      attr_reader :applied_fixes

      private

      attr_reader :package, :profile

      def record_fix(validity_rule, message)
        @applied_fixes << {
          validity_rule: validity_rule,
          message: message,
          timestamp: Time.now,
        }
      end

      # Inject a named element into a mixed_content model's element_order
      # so it gets serialized. lutaml-model 0.8.7 doesn't clear element_order
      # in clear_xml_parse_state!, so newly added attributes are invisible
      # to the serializer unless explicitly tracked.
      def ensure_element_in_order(model, tag_name, after: nil, before: nil)
        order = model.element_order
        return unless order

        return if order.any? { |e| e.name == tag_name }

        entry = Lutaml::Xml::Element.new("Element", tag_name)

        if after
          idx = order.index { |e| e.name == after }
          order.insert(idx ? idx + 1 : -1, entry)
        elsif before
          idx = order.index { |e| e.name == before }
          order.insert(idx || 0, entry)
        else
          order << entry
        end
      end

      # Clear stored namespace plans from parsed XML so that
      # declare: :always namespace_scopes take full effect during
      # serialization. Without this, parsed objects limit namespace
      # declarations to only those present in the source XML.
      def clear_stored_namespace_plans
        parts = [
          package.document,
          package.settings,
          package.font_table,
          package.styles,
          package.web_settings,
          package.numbering,
          package.core_properties,
          package.app_properties,
          package.footnotes,
          package.endnotes,
        ].compact

        parts.each do |part|
          part.import_declaration_plan = nil
          part.pending_plan_root_element = nil
        end

        parts.each(&:clear_xml_parse_state!)
      end

      def reconcile_section_properties
        return unless package.document&.body

        body = package.document.body

        unless body.section_properties
          body.section_properties = Wordprocessingml::SectionProperties.new(
            page_size: Wordprocessingml::PageSize.new(width: 12_240,
                                                      height: 15_840),
            page_margins: Wordprocessingml::PageMargins.new(
              top: 1440, right: 1440, bottom: 1440, left: 1440,
              header: 720, footer: 720, gutter: 0
            ),
            columns: Wordprocessingml::Columns.new(space: 720),
            doc_grid: Wordprocessingml::DocGrid.new(line_pitch: 360),
          )
          record_fix("R11",
                     "Added default section properties with US Letter page size")
          return
        end

        sect_pr = body.section_properties
        fixed = false
        unless sect_pr.page_size
          sect_pr.page_size = Wordprocessingml::PageSize.new(width: 12_240,
                                                             height: 15_840)
          fixed = true
        end
        unless sect_pr.page_margins
          sect_pr.page_margins = Wordprocessingml::PageMargins.new(
            top: 1440, right: 1440, bottom: 1440, left: 1440,
            header: 720, footer: 720, gutter: 0
          )
          fixed = true
        end
        unless sect_pr.columns
          sect_pr.columns = Wordprocessingml::Columns.new(space: 720)
          fixed = true
        end
        if fixed
          record_fix("R11",
                     "Filled missing pgSz/pgMar/cols in existing section properties")
        end
      end

      # -- Footnotes --

      # Extension namespace prefixes declared across all OOXML parts.
      # Must be listed in mc:Ignorable on every root element that declares them.
      EXTENSION_PREFIXES = "w14 w15 w16se w16cid w16 w16cex w16du w16sdtdh w16sdtfl"

      # Valid w:type values per OOXML spec for w:footnote/w:endnote.
      # Normal footnotes must have NO w:type attribute.
      VALID_NOTE_TYPES = %w[separator continuationSeparator
                            footnoteSeparator continuationNotice].freeze

      def reconcile_footnotes
        has_fn_pr = package.settings&.footnote_pr
        has_footnotes = package.footnotes

        if has_fn_pr && !has_footnotes
          package.footnotes = minimal_footnotes
          record_fix("R9",
                     "Created footnotes.xml to match footnotePr in settings")
        elsif has_footnotes && !has_fn_pr
          package.settings ||= Wordprocessingml::Settings.new
          package.settings.footnote_pr = Wordprocessingml::FootnotePr.new
          record_fix("R9",
                     "Added footnotePr to settings to match footnotes.xml")
        end

        if package.footnotes
          ensure_separators(package.footnotes, :footnote)
          strip_invalid_note_types(package.footnotes.footnote_entries)
          strip_empty_runs_from_notes(package.footnotes.footnote_entries)
          backfill_note_paragraphs(package.footnotes.footnote_entries, "fn")
          reorder_notes_by_reference(package.footnotes.footnote_entries, :footnote)
          renumber_notes(package.footnotes.footnote_entries, :footnote)
          package.footnotes.mc_ignorable ||= Ooxml::Types::McIgnorable.new(
            "#{EXTENSION_PREFIXES} wp14"
          )
        end
      end

      # -- Endnotes --

      def reconcile_endnotes
        has_en_pr = package.settings&.endnote_pr
        has_endnotes = package.endnotes

        if has_en_pr && !has_endnotes
          package.endnotes = minimal_endnotes
          record_fix("R9",
                     "Created endnotes.xml to match endnotePr in settings")
        elsif has_endnotes && !has_en_pr
          package.settings ||= Wordprocessingml::Settings.new
          package.settings.endnote_pr = Wordprocessingml::EndnotePr.new
          record_fix("R9", "Added endnotePr to settings to match endnotes.xml")
        end

        if package.endnotes
          ensure_separators(package.endnotes, :endnote)
          strip_invalid_note_types(package.endnotes.endnote_entries)
          strip_empty_runs_from_notes(package.endnotes.endnote_entries)
          backfill_note_paragraphs(package.endnotes.endnote_entries, "en")
          reorder_notes_by_reference(package.endnotes.endnote_entries, :endnote)
          renumber_notes(package.endnotes.endnote_entries, :endnote)
          package.endnotes.mc_ignorable ||= Ooxml::Types::McIgnorable.new(
            "#{EXTENSION_PREFIXES} wp14"
          )
        end
      end

      def strip_invalid_note_types(entries)
        entries.each do |entry|
          next unless entry.type && !VALID_NOTE_TYPES.include?(entry.type)

          record_fix("R9",
                     "Stripped invalid w:type=\"#{entry.type}\" from " \
                     "note id=#{entry.id}")
          entry.type = nil
        end
      end

      def reorder_notes_by_reference(entries, type)
        body = package.document&.body
        return unless body

        ref_order = collect_note_reference_order(body, type)
        return if ref_order.empty?

        structural = entries.select { |e| VALID_NOTE_TYPES.include?(e.type) }
        user_entries = entries.reject { |e| VALID_NOTE_TYPES.include?(e.type) }
        return if user_entries.size <= 1

        by_id = user_entries.group_by(&:id)
        reordered = ref_order.filter_map { |id| by_id[id]&.first }

        referenced_ids = ref_order.to_set
        unreferenced = user_entries.reject { |e| referenced_ids.include?(e.id) }
        reordered.concat(unreferenced)

        return if reordered == user_entries

        entries.clear
        structural.each { |e| entries << e }
        reordered.each { |e| entries << e }

        record_fix("R9", "Reordered #{type}notes by first reference in document body")
      end

      def renumber_notes(entries, type)
        user_entries = entries.reject { |e| VALID_NOTE_TYPES.include?(e.type) }
        return if user_entries.size <= 1

        id_map = {}
        user_entries.each_with_index do |entry, idx|
          old_id = entry.id
          new_id = (idx + 1).to_s
          next if old_id == new_id
          id_map[old_id] = new_id
          entry.id = new_id
        end
        return if id_map.empty?

        body = package.document&.body
        return unless body

        ref_attr = type == :footnote ? :footnote_reference : :endnote_reference
        walk_body_paragraphs(body) do |para|
          next unless para.respond_to?(:runs)
          para.runs.each do |run|
            ref = run.public_send(ref_attr)
            next unless ref && ref.id && id_map.key?(ref.id)
            ref.id = id_map[ref.id]
          end
        end

        record_fix("R9", "Renumbered #{type}note IDs sequentially (#{id_map.size} changed)")
      end

      def collect_note_reference_order(body, type)
        ref_attr = type == :footnote ? :footnote_reference : :endnote_reference
        seen = []

        walk_body_paragraphs(body) do |para|
          next unless para.respond_to?(:runs)
          para.runs.each do |run|
            ref = run.public_send(ref_attr)
            next unless ref && ref.id
            seen << ref.id unless seen.include?(ref.id)
          end
        end

        seen
      end

      def walk_body_paragraphs(body)
        if body.element_order && !body.element_order.empty?
          p_idx = 0
          tbl_idx = 0
          body.element_order.each do |entry|
            case entry.name
            when "p"
              yield body.paragraphs[p_idx] if body.paragraphs[p_idx]
              p_idx += 1
            when "tbl"
              walk_table_paragraphs(body.tables[tbl_idx]) { |p| yield p } if body.tables[tbl_idx]
              tbl_idx += 1
            end
          end
        else
          body.paragraphs.each { |p| yield p }
          body.tables&.each { |tbl| walk_table_paragraphs(tbl) { |p| yield p } }
        end
      end

      def walk_table_paragraphs(table)
        return unless table
        table.rows&.each do |row|
          row.cells&.each do |cell|
            cell.paragraphs.each { |p| yield p }
          end
        end
      end

      # -- Headers/Footers --

      def reconcile_headers_footers
        ignorable = Ooxml::Types::McIgnorable.new("#{EXTENSION_PREFIXES} wp14")
        set_header_footer_ignorable(package.document&.headers, ignorable)
        set_header_footer_ignorable(package.document&.footers, ignorable)

        rsid = generate_rsid
        backfill_part_paragraphs(package.document&.headers&.values, rsid)
        backfill_part_paragraphs(package.document&.footers&.values, rsid)
        backfill_part_paragraphs(package.document&.header_footer_parts&.map { |p| p[:content] }, rsid)
      end

      def set_header_footer_ignorable(parts, ignorable)
        return unless parts

        parts.each_value { |part| part.mc_ignorable ||= ignorable }
      end

      def clean_part_runs(parts)
        return unless parts

        parts.each do |part|
          next unless part.respond_to?(:paragraphs)
          part.paragraphs.each { |p| strip_empty_runs(p) }
        end
      end

      def backfill_part_paragraphs(parts, rsid)
        return unless parts

        parts.each_with_index do |part, pidx|
          next unless part.respond_to?(:paragraphs)
          part.paragraphs.each_with_index do |para, idx|
            strip_empty_runs(para)
            para.rsid_r ||= rsid
            para.rsid_r_default ||= "00000000"
            para.para_id ||= generate_hex_id("hf:#{pidx}:#{idx}")
            para.text_id ||= "77777777"
          end
        end
      end

      def strip_empty_runs(paragraph)
        return unless paragraph.respond_to?(:runs)

        removed = paragraph.runs.reject! { |r| empty_run?(r) }
        return unless removed && !removed.empty?

        record_fix("R10",
                   "Stripped #{removed.size} empty run(s) from " \
                   "#{paragraph.class.name.split('::').last}")
      end

      def strip_empty_runs_from_notes(entries)
        entries.each do |entry|
          next unless entry.respond_to?(:paragraphs)
          entry.paragraphs.each { |p| strip_empty_runs(p) }
        end
      end

      def backfill_note_paragraphs(entries, prefix)
        rsid = generate_rsid
        entries.each_with_index do |entry, eidx|
          next unless entry.respond_to?(:paragraphs)
          entry.paragraphs.each_with_index do |para, pidx|
            para.rsid_r ||= rsid
            para.rsid_r_default ||= "00000000"
            para.para_id ||= generate_hex_id("#{prefix}:#{eidx}:#{pidx}")
            para.text_id ||= "77777777"
          end
        end
      end

      # -- Referential Integrity --

      # Validate and fix cross-part ID consistency between document.xml
      # and other package parts (footnotes.xml, endnotes.xml, etc.).
      def reconcile_referential_integrity
        return unless package.document&.body

        reconcile_note_body_references(:footnote)
        reconcile_note_body_references(:endnote)
        reconcile_sect_pr_references
      end

      # Remove body runs that reference note IDs with no matching definition.
      def reconcile_note_body_references(type)
        notes = type == :footnote ? package.footnotes : package.endnotes
        return unless notes

        entries = type == :footnote ? notes.footnote_entries : notes.endnote_entries
        defined_ids = entries
                      .reject { |e| VALID_NOTE_TYPES.include?(e.type) }
                      .map(&:id).compact.to_set

        ref_attr = type == :footnote ? :footnote_reference : :endnote_reference
        removed = 0

        walk_body_paragraphs(package.document.body) do |para|
          next unless para.respond_to?(:runs)

          para.runs.reject! do |run|
            ref = run.public_send(ref_attr)
            next false unless ref && ref.id
            next false if defined_ids.include?(ref.id)

            removed += 1
            true
          end
        end

        return unless removed.positive?

        record_fix("R9",
                   "Removed #{removed} dangling #{type}note reference(s) in body")
      end

      # Remove sectPr header/footer references with no matching part.
      def reconcile_sect_pr_references
        sect_pr = package.document&.body&.section_properties
        return unless sect_pr

        valid_rids = collect_valid_header_footer_rids
        return if valid_rids.empty?

        removed = 0
        %i[header_references footer_references].each do |refs_attr|
          refs = sect_pr.public_send(refs_attr)
          next unless refs

          removed += refs.count { |r| r.r_id && !valid_rids.include?(r.r_id) }
          refs.reject! { |r| r.r_id && !valid_rids.include?(r.r_id) }
        end

        return unless removed.positive?

        record_fix("R11",
                   "Removed #{removed} dangling header/footer reference(s) from sectPr")
      end

      def collect_valid_header_footer_rids
        rids = Set.new

        (package.document&.header_footer_parts || []).each do |part|
          rids << part[:r_id] if part[:r_id]
        end

        if package.document_rels
          package.document_rels.relationships.each do |rel|
            t = rel.type.to_s
            if t.include?("officeDocument/2006/relationships/header") ||
               t.include?("officeDocument/2006/relationships/footer")
              rids << rel.id
            end
          end
        end

        counter = 0
        (package.document&.headers || {}).each_key do
          counter += 1
          rids << "rIdHeader#{counter}"
        end

        counter = 0
        (package.document&.footers || {}).each_key do
          counter += 1
          rids << "rIdFooter#{counter}"
        end

        rids
      end

      # -- Tables --

      # Default TableLook values per OOXML convention.
      DEFAULT_TABLE_LOOK = Properties::TableLook.new(
        val: "04A0",
        first_row: 1,
        last_row: 0,
        first_column: 1,
        last_column: 0,
        no_h_band: 0,
        no_v_band: 1,
      ).freeze

      def reconcile_tables
        return unless package.document&.body

        tables = package.document.body.tables
        return unless tables

        tables.each_with_index do |tbl, idx|
          reconcile_single_table(tbl, idx)
        end
      end

      def reconcile_single_table(tbl, idx)
        fixed = false

        # Ensure tblPr exists
        unless tbl.properties
          tbl.properties = Wordprocessingml::TableProperties.new
          fixed = true
        end

        # Ensure tblW has valid w and type
        tw = tbl.properties.table_width
        if tw.nil?
          tbl.properties.table_width = Properties::TableWidth.new(w: 0, type: "auto")
          fixed = true
        elsif tw.w.nil? || tw.type.nil?
          tw.w ||= 0
          tw.type ||= "auto"
          fixed = true
        end

        # Ensure tblLook has defaults
        if tbl.properties.table_look.nil?
          tbl.properties.table_look = Properties::TableLook.new(
            val: DEFAULT_TABLE_LOOK.val,
            first_row: DEFAULT_TABLE_LOOK.first_row,
            last_row: DEFAULT_TABLE_LOOK.last_row,
            first_column: DEFAULT_TABLE_LOOK.first_column,
            last_column: DEFAULT_TABLE_LOOK.last_column,
            no_h_band: DEFAULT_TABLE_LOOK.no_h_band,
            no_v_band: DEFAULT_TABLE_LOOK.no_v_band,
          )
          fixed = true
        elsif tbl.properties.table_look.val.nil?
          look = tbl.properties.table_look
          look.val = DEFAULT_TABLE_LOOK.val
          look.first_row ||= DEFAULT_TABLE_LOOK.first_row
          look.last_row ||= DEFAULT_TABLE_LOOK.last_row
          look.first_column ||= DEFAULT_TABLE_LOOK.first_column
          look.last_column ||= DEFAULT_TABLE_LOOK.last_column
          look.no_h_band ||= DEFAULT_TABLE_LOOK.no_h_band
          look.no_v_band ||= DEFAULT_TABLE_LOOK.no_v_band
          fixed = true
        end

        # Ensure tblGrid exists with correct column count
        col_count = tbl.column_count
        if tbl.grid.nil?
          grid_cols = Array.new(col_count) do
            Wordprocessingml::GridCol.new
          end
          tbl.grid = Wordprocessingml::TableGrid.new(columns: grid_cols)
          fixed = true
        elsif tbl.grid.columns.size != col_count
          # Adjust grid column count to match actual column count
          current = tbl.grid.columns.size
          if current < col_count
            (col_count - current).times do
              tbl.grid.columns << Wordprocessingml::GridCol.new
            end
          else
            tbl.grid.columns = tbl.grid.columns.first(col_count)
          end
          fixed = true
        end

        # Warn about grid columns missing width
        tbl.grid&.columns&.each_with_index do |col, ci|
          next if col.width

          Uniword.logger&.warn do
            "Table #{idx}: gridCol[#{ci}] has no w:w — " \
            "table may render with incorrect column widths"
          end
        end

        record_fix("R10", "Reconciled table structure for table #{idx}") if fixed

        # Ensure every cell has tcPr with tcW
        tbl.rows&.each do |row|
          row.cells&.each do |cell|
            tc_pr = cell.properties
            if tc_pr.nil?
              cell.properties = Wordprocessingml::TableCellProperties.new(
                cell_width: Uniword::Properties::CellWidth.new(w: 0, type: "auto"),
              )
              insert_element_order(cell, "tcPr", 0)
              record_fix("R12", "Added missing tcPr with tcW to table cell")
            elsif tc_pr.cell_width.nil?
              tc_pr.cell_width = Uniword::Properties::CellWidth.new(w: 0, type: "auto")
              record_fix("R12", "Added missing tcW to table cell")
            end

            reconcile_table_cell_order(cell)
          end
        end

        # Ensure gridAfter for rows that don't cover all grid columns
        grid_col_count = tbl.grid&.columns&.size || 0
        if grid_col_count.positive?
          tbl.rows&.each do |row|
            cells = row.cells
            next unless cells && !cells.empty?

            covered = cells.sum do |cell|
              span = cell.properties&.grid_span&.value
              span && span > 0 ? span : 1
            end

            missing = grid_col_count - covered
            next if missing <= 0

            row_props = row.properties
            if row_props.nil?
              row.properties = Wordprocessingml::TableRowProperties.new(
                grid_after: Wordprocessingml::GridAfter.new(value: missing),
              )
              insert_element_order(row, "trPr", 0)
            elsif row_props.grid_after.nil? || row_props.grid_after.value != missing
              row_props.grid_after ||= Wordprocessingml::GridAfter.new
              row_props.grid_after.value = missing
            end
            record_fix("R13", "Added gridAfter=#{missing} to table row (grid has #{grid_col_count} cols, row covers #{covered})")
          end
        end
      end

      def reconcile_table_cell_order(cell)
        return unless cell.respond_to?(:element_order)

        order = cell.element_order
        return unless order && !order.empty?

        tcPr_idx = order.index { |e| e.name == "tcPr" }
        first_p_idx = order.index { |e| e.name == "p" }

        return if tcPr_idx.nil? || first_p_idx.nil?
        return if tcPr_idx < first_p_idx

        # Move tcPr before the first p
        tcPr_entry = order.delete_at(tcPr_idx)
        order.insert(first_p_idx, tcPr_entry)

        record_fix("R10", "Moved tcPr before p in table cell")
      end

      def insert_element_order(obj, name, position)
        return unless obj.respond_to?(:element_order)

        order = obj.element_order
        return unless order

        already = order.any? { |e| e.name == name }
        return if already

        entry = Lutaml::Xml::Element.new("Element", name, node_type: :element)
        order.insert(position, entry)
      end

      # -- Note reference consistency --

      def reconcile_note_references
        reconcile_footnote_references
        reconcile_endnote_references
        reconcile_note_definition_integrity
      end

      def reconcile_footnote_references
        return unless package.document&.body

        referenced = collect_note_ids(:footnote)
        return if referenced.empty?

        ensure_footnotes_part
        defined = package.footnotes.footnote_entries.each_with_object(Set.new) do |fn, s|
          s << fn.id
        end

        missing = referenced.to_set - defined
        return if missing.empty?

        missing.each do |id|
          package.footnotes.footnote_entries << Wordprocessingml::Footnote.new(
            id: id, paragraphs: [Wordprocessingml::Paragraph.new],
          )
        end
        record_fix("R10",
                   "Added #{missing.size} missing footnote definition(s) " \
                   "for orphaned footnoteReference IDs: #{missing.sort.join(', ')}")
      end

      def reconcile_endnote_references
        return unless package.document&.body

        referenced = collect_note_ids(:endnote)
        return if referenced.empty?

        ensure_endnotes_part
        defined = package.endnotes.endnote_entries.each_with_object(Set.new) do |en, s|
          s << en.id
        end

        missing = referenced.to_set - defined
        return if missing.empty?

        missing.each do |id|
          package.endnotes.endnote_entries << Wordprocessingml::Endnote.new(
            id: id, paragraphs: [Wordprocessingml::Paragraph.new],
          )
        end
        record_fix("R10",
                   "Added #{missing.size} missing endnote definition(s) " \
                   "for orphaned endnoteReference IDs: #{missing.sort.join(', ')}")
      end

      # Validates structural integrity of footnote/endnote definitions.
      def reconcile_note_definition_integrity
        strip_invalid_note_types(:footnote)
        strip_invalid_note_types(:endnote)
        deduplicate_note_ids(:footnote)
        deduplicate_note_ids(:endnote)
      end

      # R15: Regular footnotes/endnotes must NOT have w:type.
      # Only separator (id=-1) and continuationSeparator (id=0) use w:type.
      def strip_invalid_note_types(type)
        notes = package.public_send(:"#{type}s")
        return unless notes

        entries = notes.public_send(:"#{type}_entries")
        invalid = entries.select do |e|
          e.type && e.id != "-1" && e.id != "0"
        end
        return if invalid.empty?

        invalid.each { |e| e.type = nil }
        record_fix("R15",
                   "Removed invalid w:type from #{invalid.size} " \
                   "regular #{type} definition(s): " \
                   "IDs #{invalid.map(&:id).sort.join(', ')}")
      end

      # R16: Duplicate IDs in footnotes.xml/endnotes.xml are invalid.
      # Keeps the first occurrence, removes subsequent duplicates.
      def deduplicate_note_ids(type)
        notes = package.public_send(:"#{type}s")
        return unless notes

        entries = notes.public_send(:"#{type}_entries")
        seen = Set.new
        dupes = []
        entries.reject! do |e|
          if seen.include?(e.id)
            dupes << e
            true
          else
            seen << e.id
            false
          end
        end
        return if dupes.empty?

        record_fix("R16",
                   "Removed #{dupes.size} duplicate #{type} ID(s): " \
                   "#{dupes.map(&:id).sort.join(', ')}")
      end

      # -- Builders --

      def minimal_footnotes
        Wordprocessingml::Footnotes.new(
          footnote_entries: [separator_entry(:footnote),
                             continuation_entry(:footnote)],
        )
      end

      def minimal_endnotes
        Wordprocessingml::Endnotes.new(
          endnote_entries: [separator_entry(:endnote),
                            continuation_entry(:endnote)],
        )
      end

      def separator_entry(type)
        entry_class(type).new(
          id: "-1", type: "separator",
          paragraphs: [separator_paragraph(:separator)]
        )
      end

      def continuation_entry(type)
        entry_class(type).new(
          id: "0", type: "continuationSeparator",
          paragraphs: [separator_paragraph(:continuation)]
        )
      end

      def separator_paragraph(kind = :separator)
        sep_run = Wordprocessingml::Run.new(
          kind == :separator ? { separator_char: Wordprocessingml::SeparatorChar.new } :
                               { continuation_separator_char: Wordprocessingml::ContinuationSeparatorChar.new }
        )
        Wordprocessingml::Paragraph.new(
          properties: Wordprocessingml::ParagraphProperties.new(
            spacing: Properties::Spacing.new(after: 0, line: 240,
                                             line_rule: "auto"),
          ),
          runs: [sep_run]
        )
      end

      def entry_class(type)
        type == :footnote ? Wordprocessingml::Footnote : Wordprocessingml::Endnote
      end

      def ensure_separators(notes, type)
        entries = notes.public_send(:"#{type}_entries")

        entries.each do |entry|
          next unless %w[separator continuationSeparator].include?(entry.type)
          next if entry.paragraphs.empty?

          entry.paragraphs.each do |p|
            clean_separator_paragraph(p)
            ensure_separator_run(p, entry.type)
          end
        end

        ids = entries.to_set(&:id)
        entries.unshift(separator_entry(type)) unless ids.include?("-1")
        entries.unshift(continuation_entry(type)) unless ids.include?("0")
      end

      def collect_note_ids(type)
        ref_attr = type == :footnote ? :footnote_reference : :endnote_reference
        ids = []
        collect_note_ids_from_element(package.document.body, ref_attr, ids)
        ids
      end

      def collect_note_ids_from_element(element, ref_attr, ids)
        return unless element

        collect_note_ids_from_paragraphs(element.paragraphs, ref_attr, ids)

        tables = element.tables
        return unless tables
        tables.each do |tbl|
          tbl.rows.each do |row|
            row.cells.each do |cell|
              collect_note_ids_from_paragraphs(cell.paragraphs, ref_attr, ids)
            end
          end
        end
      end

      def collect_note_ids_from_paragraphs(paragraphs, ref_attr, ids)
        return unless paragraphs
        paragraphs.each do |p|
          (p.runs || []).each do |r|
            ref = r.public_send(ref_attr)
            ids << ref.id if ref&.id
          end
        end
      end

      def ensure_footnotes_part
        return if package.footnotes

        package.footnotes = minimal_footnotes
        record_fix("R9", "Created footnotes.xml for orphaned references")
      end

      def ensure_endnotes_part
        return if package.endnotes

        package.endnotes = minimal_endnotes
        record_fix("R9", "Created endnotes.xml for orphaned references")
      end

      def clean_separator_paragraph(para)
        para.runs.reject! { |r| empty_run?(r) }
      end

      def ensure_separator_run(para, type)
        has_sep = para.runs.any? { |r| r.separator_char || r.continuation_separator_char }
        return if has_sep

        sep = if type == "separator"
                Wordprocessingml::Run.new(separator_char: Wordprocessingml::SeparatorChar.new)
              else
                Wordprocessingml::Run.new(continuation_separator_char: Wordprocessingml::ContinuationSeparatorChar.new)
              end
        para.runs << sep
      end

      def empty_run?(run)
        return false if run.break
        return false if run.tab
        return false if run.drawings&.any?
        return false if run.pictures&.any?
        return false if run.alternate_content
        return false if run.footnote_reference
        return false if run.endnote_reference
        return false if run.field_char
        return false if run.instr_text
        return false if run.position_tab
        return false if run.del_text
        return false if run.no_break_hyphen
        return false if run.sym
        return false if run.last_rendered_page_break
        return false if run.separator_char
        return false if run.continuation_separator_char

        t = run.text
        return true unless t

        content = t.content if t.class.attributes.key?(:content)
        content = t.value if content.nil? && t.class.attributes.key?(:value)
        !content.is_a?(String) || content.empty?
      end

      # -- Group 2: Support parts (profile-dependent) --

      def reconcile_theme
        return unless profile
        return if package.theme

        theme_name = profile.system.default_theme_name
        return unless theme_name

        begin
          friendly = Themes::Theme.load(theme_name)
          word_theme = friendly.to_word_theme
          word_theme.name = "Office Theme"
          package.theme = word_theme
          record_fix("R3", "Created default theme with complete fmtScheme")
        rescue ArgumentError
          nil
        end
      end

      # Repair broken theme fmtScheme even without a profile.
      # Word replaces the entire theme on repair; we fill minimum content.
      def repair_theme
        theme = package.theme
        return unless theme

        fmt = theme.theme_elements&.fmt_scheme
        return unless fmt

        repaired = false

        if count_fill_styles(fmt.fill_style_lst) < 2
          ensure_minimal_fill_list(fmt)
          repaired = true
        end

        if count_line_styles(fmt.ln_style_lst) < 3
          ensure_minimal_line_list(fmt)
          repaired = true
        end

        if count_effect_styles(fmt.effect_style_lst) < 3
          ensure_minimal_effect_list(fmt)
          repaired = true
        end

        if count_fill_styles(fmt.bg_fill_style_lst) < 2
          ensure_minimal_bg_fill_list(fmt)
          repaired = true
        end

        if repaired
          record_fix("R3",
                     "Repaired theme fmtScheme with minimum required content")
        end
      end

      def count_fill_styles(lst)
        return 0 unless lst

        (lst.solid_fills || []).size + (lst.gradient_fills || []).size + (lst.blip_fills || []).size
      end

      def count_line_styles(lst)
        return 0 unless lst

        (lst.lines || []).size
      end

      def count_effect_styles(lst)
        return 0 unless lst

        (lst.effect_styles || []).size
      end

      def ensure_minimal_fill_list(fmt)
        lst = fmt.fill_style_lst || Drawingml::FillStyleList.new
        fills = Array(lst.solid_fills).dup
        while fills.size < 2
          fills << Drawingml::SolidFill.new(
            scheme_color: Drawingml::SchemeColor.new(val: "accent#{fills.size + 1}"),
          )
        end
        lst.solid_fills = fills
        fmt.fill_style_lst = lst
      end

      def ensure_minimal_line_list(fmt)
        lst = fmt.ln_style_lst || Drawingml::LineStyleList.new
        lines = Array(lst.lines).dup
        widths = [9525, 25400, 38100]
        while lines.size < 3
          idx = lines.size
          lines << Drawingml::LineProperties.new(
            width: widths[idx] || 9525,
            solid_fill: Drawingml::SolidFill.new(
              scheme_color: Drawingml::SchemeColor.new(val: "accent#{idx + 1}"),
            ),
          )
        end
        lst.lines = lines
        fmt.ln_style_lst = lst
      end

      def ensure_minimal_effect_list(fmt)
        lst = fmt.effect_style_lst || Drawingml::EffectStyleList.new
        styles = Array(lst.effect_styles).dup
        while styles.size < 3
          styles << Drawingml::EffectStyle.new
        end
        lst.effect_styles = styles
        fmt.effect_style_lst = lst
      end

      def ensure_minimal_bg_fill_list(fmt)
        lst = fmt.bg_fill_style_lst || Drawingml::BackgroundFillStyleList.new
        fills = Array(lst.solid_fills).dup
        while fills.size < 2
          fills << Drawingml::SolidFill.new(
            scheme_color: Drawingml::SchemeColor.new(val: "accent#{fills.size + 1}"),
          )
        end
        lst.solid_fills = fills
        fmt.bg_fill_style_lst = lst
      end

      def reconcile_settings
        return unless profile

        new_settings = package.settings.nil?
        settings = package.settings
        settings ||= begin
          package.settings = Wordprocessingml::Settings.new
          package.settings
        end

        rsid = generate_rsid

        # Only inject settings defaults for newly created documents.
        # If settings already has substantial content (zoom + compat + rsids),
        # the document was loaded from a real DOCX and defaults would alter
        # its round-trip fidelity.
        loaded_doc = settings.zoom && settings.compat && settings.rsids

        settings.zoom ||= Wordprocessingml::Zoom.new(percent: 100)
        if new_settings && settings.do_not_display_page_boundaries.nil?
          settings.do_not_display_page_boundaries = Wordprocessingml::DoNotDisplayPageBoundaries.new
          ensure_element_in_order(settings, "doNotDisplayPageBoundaries", after: "zoom")
        end
        settings.proof_state ||= Wordprocessingml::ProofState.new(
          spelling: "clean", grammar: "clean",
        ) unless loaded_doc
        settings.default_tab_stop ||= Wordprocessingml::DefaultTabStop.new(val: "720")
        settings.character_spacing_control ||= Wordprocessingml::CharacterSpacingControl.new(
          val: "doNotCompress",
        )

        settings.compat ||= build_compat
        settings.rsids ||= build_rsids(rsid)
        settings.math_pr ||= build_math_pr
        settings.theme_font_lang ||= Wordprocessingml::ThemeFontLang.new(
          val: profile.lang,
          east_asia: profile.east_asia_lang,
        )
        settings.clr_scheme_mapping ||= build_clr_scheme_mapping
        settings.decimal_symbol ||= Wordprocessingml::DecimalSymbol.new(
          val: profile.decimal_symbol,
        )
        settings.list_separator ||= Wordprocessingml::ListSeparator.new(
          val: profile.list_separator,
        )

        unless settings.w14_doc_id
          settings.w14_doc_id = Wordprocessingml::W14DocId.new(
            val: hex_derive("w14_doc_id", 4),
          )
          record_fix("R2", "Generated w14:docId")
        end
        unless settings.w15_doc_id
          raw = hex_derive("w15_doc_id", 16)
          formatted = "#{raw[0..7]}-#{raw[8..11]}-#{raw[12..15]}-#{raw[16..19]}-#{raw[20..31]}"
          settings.w15_doc_id = Wordprocessingml::W15DocId.new(
            val: "{#{formatted.upcase}}",
          )
          record_fix("R2", "Generated w15:docId in GUID format")
        end

        settings.mc_ignorable ||= Ooxml::Types::McIgnorable.new(EXTENSION_PREFIXES)
      end

      def reconcile_font_table
        return unless profile

        font_table = package.font_table
        font_table ||= begin
          package.font_table = Wordprocessingml::FontTable.new
          record_fix("R13", "Created font table")
          package.font_table
        end

        font_table.mc_ignorable ||= Ooxml::Types::McIgnorable.new(EXTENSION_PREFIXES)

        return unless font_table.fonts.empty?

        metadata = load_font_metadata
        return unless metadata

        font_names = font_names_for_profile
        font_names.each do |name|
          meta = metadata[name]
          next unless meta

          sig_data = meta["sig"] || {}
          font = Wordprocessingml::Font.new(
            name: name,
            panose1: Wordprocessingml::Panose1.new(val: meta["panose1"]),
            charset: Wordprocessingml::Charset.new(val: meta["charset"]),
            family: Wordprocessingml::Family.new(val: meta["family"]),
            pitch: Wordprocessingml::Pitch.new(val: meta["pitch"]),
            sig: Wordprocessingml::Sig.new(
              usb0: sig_data["usb0"], usb1: sig_data["usb1"],
              usb2: sig_data["usb2"], usb3: sig_data["usb3"],
              csb0: sig_data["csb0"], csb1: sig_data["csb1"]
            ),
          )

          font.alt_name = Wordprocessingml::AltName.new(val: meta["alt_name"]) if meta["alt_name"]
          font_table.fonts << font
        end

        font_table.mc_ignorable ||= Ooxml::Types::McIgnorable.new(EXTENSION_PREFIXES)
        record_fix("R13",
                   "Populated font table with profile fonts and signatures")
      end

      def reconcile_styles
        return unless profile

        styles = package.styles
        styles ||= begin
          package.styles = Wordprocessingml::StylesConfiguration.new(include_defaults: false)
          package.styles
        end

        styles.doc_defaults ||= build_doc_defaults
        styles.latent_styles ||= build_latent_styles

        ensure_default_styles(styles)

        styles.mc_ignorable ||= Ooxml::Types::McIgnorable.new(EXTENSION_PREFIXES)
        record_fix("R10",
                   "Ensured styles have docDefaults, latentStyles, and default styles")
      end

      def reconcile_numbering
        return unless profile
        return unless package.numbering

        # Generate durableId for instances that don't have one
        package.numbering.instances.each_with_index do |inst, idx|
          next if inst.durable_id

          raw = hex_derive("durableId:#{inst.num_id}:#{idx}", 4).to_i(16)
          # ST_DecimalNumber is signed 32-bit; convert unsigned to signed
          raw = raw - 0x100000000 if raw >= 0x80000000
          inst.durable_id = raw.to_s
          record_fix("R4",
                     "Generated w16cid:durableId for numId=#{inst.num_id}")
        end

        # Validate instance → definition references
        package.numbering.instances.each do |inst|
          next unless inst.abstract_num_id

          abs_id = inst.abstract_num_id.is_a?(Uniword::Wordprocessingml::AbstractNumId) ? inst.abstract_num_id.val : inst.abstract_num_id
          defn = package.numbering.definitions.find do |d|
            d.abstract_num_id == abs_id
          end
          next if defn

          record_fix("R4", "Numbering instance numId=#{inst.num_id} references " \
                           "missing abstractNumId=#{abs_id}")
        end
      end

      def reconcile_web_settings
        return unless profile

        ws = package.web_settings
        ws ||= begin
          package.web_settings = Wordprocessingml::WebSettings.new
          package.web_settings
        end

        ws.mc_ignorable ||= Ooxml::Types::McIgnorable.new(EXTENSION_PREFIXES)
        ws.allow_png ||= Wordprocessingml::AllowPng.new
        record_fix("R1", "Set mc:Ignorable and allowPNG on webSettings")
      end

      def reconcile_app_properties
        return unless profile

        app = package.app_properties
        app ||= begin
          package.app_properties = Ooxml::AppProperties.new
          package.app_properties
        end

        # Always assign to override lutaml-model's using_default tracking,
        # which prevents serialization of attributes that equal their defaults.
        app.template = "Normal.dotm"
        app.application = profile.application_name
        app.app_version = profile.app_version
        app.company = profile.user_company if profile.user_company && !profile.user_company.empty?

        # Calculate document statistics only when missing
        unless app.pages && !app.pages.to_s.empty?
          stats = calculate_document_statistics
          app.pages = stats[:pages].to_s
          app.words = stats[:words].to_s
          app.characters = stats[:characters].to_s
          app.characters_with_spaces = stats[:characters_with_spaces].to_s
          app.paragraphs = stats[:paragraphs].to_s
          app.lines = stats[:lines].to_s
        end

        # Re-assign to clear lutaml-model's @using_default tracking
        # which otherwise omits these from XML output.
        # Preserve source values when present.
        app.total_time = app.total_time || "0"
        app.scale_crop = app.scale_crop || "false"
        app.doc_security = app.doc_security || "0"
        app.links_up_to_date = app.links_up_to_date || "false"
        app.shared_doc = app.shared_doc || "false"
        app.hyperlinks_changed = app.hyperlinks_changed || "false"

        # HeadingPairs and TitlesOfParts are NOT generated here.
        # Word repairs files that have incorrect values, so we only
        # preserve what was parsed from the source document.
        record_fix("R8", "Ensured app properties with statistics")
      end

      def reconcile_core_properties
        return unless profile

        # Rebuild from parsed state to ensure namespace_scope
        # declarations (e.g. xmlns:dcmitype) are applied on
        # serialization (lutaml-model preserves parsed namespaces)
        old_cp = package.core_properties
        package.core_properties = if old_cp
                                    Ooxml::CoreProperties.new(
                                      title: old_cp.title,
                                      subject: old_cp.subject,
                                      creator: old_cp.creator,
                                      keywords: old_cp.keywords,
                                      description: old_cp.description,
                                      last_modified_by: old_cp.last_modified_by,
                                      revision: old_cp.revision,
                                      created: old_cp.created,
                                      modified: old_cp.modified,
                                    )
                                  else
                                    Ooxml::CoreProperties.new
                                  end
        cp = package.core_properties

        if profile.user_name && !profile.user_name.empty?
          cp.last_modified_by = profile.user_name
          cp.creator ||= profile.user_name
        end

        cp.last_modified_by ||= profile.application_name

        now = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
        cp.modified = Ooxml::Types::DctermsModifiedType.new(
          value: now, type: "dcterms:W3CDTF",
        )
        cp.created ||= Ooxml::Types::DctermsCreatedType.new(
          value: now, type: "dcterms:W3CDTF",
        )

        cp.revision = "1" unless cp.revision
        record_fix("R14", "Rebuilt core properties with namespace declarations")
      end

      def reconcile_document_body
        return unless profile
        return unless package.document&.body

        doc = package.document
        doc.mc_ignorable ||= Ooxml::Types::McIgnorable.new(
          "#{EXTENSION_PREFIXES} wp14"
        )

        record_fix("R1", "Added mc:Ignorable to document body")
        record_fix("R12", "Assigned rsid and paraId to paragraphs")

        rsid = generate_rsid
        body = doc.body

        body.paragraphs.each_with_index do |para, idx|
          para.rsid_r ||= rsid
          para.rsid_r_default ||= "00000000"
          para.para_id ||= generate_hex_id(idx)
          para.text_id ||= "77777777"
          strip_empty_runs(para)
        end

        sect_pr = body.section_properties
        return unless sect_pr

        sect_pr.rsid_r ||= rsid
      end

      # -- Group 3: Package consistency (always) --

      def reconcile_content_types
        ct = package.content_types
        return unless ct

        # Defaults: only rels + xml (image types added by inject_image_parts)
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

        # Overrides: rebuild for standard parts that exist
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
          ["rId1", "styles", "styles.xml", package.styles],
          ["rId2", "settings", "settings.xml", package.settings],
          ["rId3", "webSettings", "webSettings.xml", package.web_settings],
          ["rId4", "fontTable", "fontTable.xml", package.font_table],
          ["rId5", "theme", "theme/theme1.xml", package.theme],
          ["rId6", "numbering", "numbering.xml", package.numbering],
        ]

        standard_targets = defs.filter_map do |_, _, target, obj|
          target if obj
        end.to_set
        standard_rids = defs.filter_map { |rid, _, _, obj| rid if obj }.to_set
        non_standard = rels.relationships.reject do |r|
          standard_targets.include?(r.target) || standard_rids.include?(r.id)
        end

        # Reuse existing rIds for matching targets to avoid duplicates
        existing_by_target = rels.relationships.to_h { |r| [r.target, r] }
        standard = defs.filter_map do |_rid, suffix, target, obj|
          next unless obj

          existing = existing_by_target[target]
          rid = existing ? existing.id : _rid
          build_rel(rid, "#{base}/#{suffix}", target)
        end

        rels.relationships = standard + non_standard
        record_fix("R6", "Rebuilt document relationships for standard parts")
      end

      # -- Helpers --

      def calculate_document_statistics
        DocumentStatistics.new(package).calculate
      end

      def generate_rsid
        "00#{hex_derive("rsid", 3)}"
      end

      def generate_hex_id(seed = 0)
        hex_derive("paraId:#{seed}", 4)
      end

      def hex_derive(seed, byte_count)
        Digest::SHA256.hexdigest("#{document_fingerprint}:#{seed}")[0...(byte_count * 2)].upcase
      end

      def document_fingerprint
        @document_fingerprint ||= begin
          body = package.document&.body
          return "empty" unless body

          texts = (body.paragraphs || []).map do |p|
            (p.runs || []).map { |r| r.text.to_s }.join
          end
          Digest::SHA256.hexdigest(texts.join("|"))
        end
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

      def build_rel(id, type, target)
        Ooxml::Relationships::Relationship.new(
          id: id, type: type, target: target,
        )
      end

      def build_compat
        Wordprocessingml::Compat.new(
          use_fe_layout: Wordprocessingml::UseFELayout.new,
          compatSetting: [
            Wordprocessingml::CompatSetting.new(
              name: "compatibilityMode",
              uri: "http://schemas.microsoft.com/office/word",
              val: profile.compat_mode,
            ),
            Wordprocessingml::CompatSetting.new(
              name: "overrideTableStyleFontSizeAndJustification",
              uri: "http://schemas.microsoft.com/office/word",
              val: "1",
            ),
            Wordprocessingml::CompatSetting.new(
              name: "enableOpenTypeFeatures",
              uri: "http://schemas.microsoft.com/office/word",
              val: "1",
            ),
            Wordprocessingml::CompatSetting.new(
              name: "doNotFlipMirrorIndents",
              uri: "http://schemas.microsoft.com/office/word",
              val: "1",
            ),
            Wordprocessingml::CompatSetting.new(
              name: "differentiateMultirowTableHeaders",
              uri: "http://schemas.microsoft.com/office/word",
              val: "1",
            ),
            Wordprocessingml::CompatSetting.new(
              name: "useWord2013TrackBottomHyphenation",
              uri: "http://schemas.microsoft.com/office/word",
              val: "0",
            ),
          ],
        )
      end

      def build_rsids(rsid)
        root = "00#{hex_derive("rsid_root", 3)}"
        Wordprocessingml::Rsids.new(
          rsid_root: Wordprocessingml::RsidRoot.new(val: root),
          rsid: [Wordprocessingml::Rsid.new(val: rsid)],
        )
      end

      def build_math_pr
        Wordprocessingml::MathPr.new(
          math_font: Wordprocessingml::MathFont.new(val: "Cambria Math"),
          brk_bin: Wordprocessingml::BrkBin.new(val: "before"),
          brk_bin_sub: Wordprocessingml::BrkBinSub.new(val: "--"),
          small_frac: Wordprocessingml::SmallFrac.new(val: "0"),
          disp_def: Wordprocessingml::DispDef.new,
          l_margin: Wordprocessingml::LMargin.new(val: "0"),
          r_margin: Wordprocessingml::RMargin.new(val: "0"),
          def_jc: Wordprocessingml::DefJc.new(val: "centerGroup"),
          wrap_indent: Wordprocessingml::WrapIndent.new(val: "1440"),
          int_lim: Wordprocessingml::IntLim.new(val: "subSup"),
          nary_lim: Wordprocessingml::NaryLim.new(val: "undOvr"),
        )
      end

      def build_clr_scheme_mapping
        Wordprocessingml::ClrSchemeMapping.new(
          bg1: "light1", t1: "dark1", bg2: "light2", t2: "dark2",
          accent1: "accent1", accent2: "accent2", accent3: "accent3",
          accent4: "accent4", accent5: "accent5", accent6: "accent6",
          hyperlink: "hyperlink", followed_hyperlink: "followedHyperlink"
        )
      end

      def build_doc_defaults
        r_pr = Wordprocessingml::RunProperties.new(
          fonts: Properties::RunFonts.new(
            ascii_theme: "minorHAnsi",
            east_asia_theme: "minorEastAsia",
            h_ansi_theme: "minorHAnsi",
            cs_theme: "minorBidi",
          ),
          kerning: Properties::Kerning.new(value: 2),
          size: Properties::FontSize.new(value: 24),
          size_cs: Properties::FontSize.new(value: 24),
          language: Properties::Language.new(
            val: profile.lang,
            east_asia: profile.east_asia_lang,
            bidi: profile.bidi_lang,
          ),
          ligatures: Uniword::Wordprocessingml2010::Ligatures.new(
            val: "standardContextual",
          ),
        )

        p_pr = Wordprocessingml::ParagraphProperties.new(
          spacing: Properties::Spacing.new(after: 160, line: 278,
                                           line_rule: "auto"),
        )

        Wordprocessingml::DocDefaults.new(
          rPrDefault: Wordprocessingml::RPrDefault.new(rPr: r_pr),
          pPrDefault: Wordprocessingml::PPrDefault.new(pPr: p_pr),
        )
      end

      def build_latent_styles
        config = load_latent_styles_config
        return Wordprocessingml::LatentStyles.new(count: 0) unless config

        exceptions = (config["exceptions"] || []).map do |ex|
          attrs = { name: ex["name"] }
          attrs[:ui_priority] = ex["uiPriority"].to_i if ex["uiPriority"]
          attrs[:q_format] = ex["qFormat"] if ex["qFormat"]
          attrs[:semi_hidden] = ex["semiHidden"] if ex["semiHidden"]
          if ex["unhideWhenUsed"]
            attrs[:unhide_when_used] =
              ex["unhideWhenUsed"]
          end
          attrs[:locked] = ex["locked"] if ex["locked"]
          Wordprocessingml::LatentStylesException.new(attrs)
        end

        Wordprocessingml::LatentStyles.new(
          def_locked_state: config["defLockedState"],
          def_ui_priority: config["defUIPriority"].to_i,
          def_semi_hidden: config["defSemiHidden"],
          def_unhide_when_used: config["defUnhideWhenUsed"],
          def_q_format: config["defQFormat"],
          count: config["count"].to_i,
          lsd_exception: exceptions,
        )
      end

      def ensure_default_styles(styles)
        style_ids = styles.styles.to_set(&:id)

        unless style_ids.include?("Normal")
          styles.add_style(Wordprocessingml::Style.new(
                             type: "paragraph", default: true, styleId: "Normal",
                             name: Wordprocessingml::StyleName.new(val: "Normal"),
                             qFormat: Properties::QuickFormat.new
                           ))
        end

        unless style_ids.include?("DefaultParagraphFont")
          styles.add_style(Wordprocessingml::Style.new(
                             type: "character", default: true, styleId: "DefaultParagraphFont",
                             name: Wordprocessingml::StyleName.new(val: "Default Paragraph Font"),
                             uiPriority: Wordprocessingml::UiPriority.new(val: 1),
                             semiHidden: Wordprocessingml::SemiHidden.new,
                             unhideWhenUsed: Wordprocessingml::UnhideWhenUsed.new
                           ))
        end

        # Ensure semiHidden on DefaultParagraphFont even when from template
        dpf = styles.styles.find { |s| s.id == "DefaultParagraphFont" }
        if dpf && !dpf.semiHidden
          dpf.semiHidden = Wordprocessingml::SemiHidden.new
          record_fix("R10", "Added semiHidden to DefaultParagraphFont style")
        end

        unless style_ids.include?("TableNormal")
          tbl_pr = Wordprocessingml::TableProperties.new(
            table_indent: Properties::TableIndent.new(value: 0, type: "dxa"),
            table_cell_margin: Properties::TableCellMargin.new(
              top: Properties::Margin.new(w: 0, type: "dxa"),
              left: Properties::Margin.new(w: 108, type: "dxa"),
              bottom: Properties::Margin.new(w: 0, type: "dxa"),
              right: Properties::Margin.new(w: 108, type: "dxa"),
            ),
          )

          styles.add_style(Wordprocessingml::Style.new(
                             type: "table", default: true, styleId: "TableNormal",
                             name: Wordprocessingml::StyleName.new(val: "Normal Table"),
                             uiPriority: Wordprocessingml::UiPriority.new(val: 99),
                             semiHidden: Wordprocessingml::SemiHidden.new,
                             unhideWhenUsed: Wordprocessingml::UnhideWhenUsed.new,
                             tblPr: tbl_pr
                           ))
        end

        return if style_ids.include?("NoList")

        styles.add_style(Wordprocessingml::Style.new(
                           type: "numbering", default: true, styleId: "NoList",
                           name: Wordprocessingml::StyleName.new(val: "No List"),
                           uiPriority: Wordprocessingml::UiPriority.new(val: 99),
                           semiHidden: Wordprocessingml::SemiHidden.new,
                           unhideWhenUsed: Wordprocessingml::UnhideWhenUsed.new
                         ))
      end

      def load_font_metadata
        path = File.join(CONFIG_DIR, "font_metadata.yml")
        YAML.load_file(path)["fonts"]
      rescue StandardError => e
        Uniword.logger&.warn { "Font metadata load failed: #{e.message}" }
        nil
      end

      def load_latent_styles_config
        path = File.join(CONFIG_DIR, "latent_styles.yml")
        YAML.load_file(path)
      rescue StandardError => e
        Uniword.logger&.warn do
          "Latent styles config load failed: #{e.message}"
        end
        nil
      end

      def font_names_for_profile
        names = []
        fs = profile.system.font_scheme
        loc = profile.locale

        # Order matches Word's canonical output:
        # 1. Minor font (body), 2. East Asian font, 3. Legacy serif,
        # 4. East Asian light font, 5. Major font (headings)
        names << fs&.minor_font if fs&.minor_font

        ea_font = loc&.east_asian_font
        ea_light = loc&.east_asian_light_font

        # Default East Asian fonts for zh-CN when locale profile omits them
        if loc.east_asia_lang == "zh-CN"
          ea_font ||= "DengXian"
          ea_light ||= "DengXian Light"
        end

        names << ea_font if ea_font
        names << "Times New Roman"
        names << ea_light if ea_light
        names << fs&.major_font if fs&.major_font

        names.uniq
      end
    end
  end
end
