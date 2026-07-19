# frozen_string_literal: true

require "digest"
require "set"
require "yaml"

module Uniword
  module Docx
    class Reconciler
      # Shared helpers used across all reconciliation modules.
      #
      # Provides ID generation, document traversal, element_order
      # manipulation, run utilities, and YAML config loading.
      module Helpers
        # -- ID generation --

        def generate_rsid
          "00#{hex_derive("rsid", 3)}"
        end

        def generate_hex_id(seed = 0)
          hex_derive("paraId:#{seed}", 4)
        end

        def hex_derive(seed, byte_count)
          Digest::SHA256.hexdigest(
            "#{document_fingerprint}:#{seed}"
          )[0...(byte_count * 2)].upcase
        end

        def document_fingerprint
          @document_fingerprint ||= begin
            body = package.document&.body
            return "empty" unless body

            texts = []
            walk_body_paragraphs(body) do |para|
              texts << (para.runs || []).map(&:text_string).join
            end
            Digest::SHA256.hexdigest(texts.join("|"))
          end
        end

        # -- Traversal --

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
                if body.tables[tbl_idx]
                  walk_table_paragraphs(body.tables[tbl_idx]) { |p| yield p }
                end
                tbl_idx += 1
              end
            end
          else
            body.paragraphs.each { |p| yield p }
            body.tables&.each { |tbl| walk_table_paragraphs(tbl) { |p| yield p } }
          end
        end

        def walk_body_tables(body)
          return unless body

          if body.element_order && !body.element_order.empty?
            tbl_idx = 0
            body.element_order.each do |entry|
              next unless entry.name == "tbl"

              yield body.tables[tbl_idx] if body.tables[tbl_idx]
              tbl_idx += 1
            end
          else
            body.tables&.each { |tbl| yield tbl }
          end
        end

        def walk_all_paragraphs(&block)
          walk_body_paragraphs(package.document.body, &block)

          (package.document&.header_footer_parts || []).each do |part|
            (part.content&.paragraphs || []).each(&block)
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

        # -- Element order (delegates to Ooxml::ElementOrder) --

        # Idempotent singleton insert in schema position.
        def ensure_element_in_order(model, tag_name, after: nil, before: nil)
          Ooxml::ElementOrder.insert_once(model, tag_name,
                                          after: after, before: before)
        end

        # Positional insert for repeatable elements.
        def insert_element_order(obj, name, position)
          order = obj.element_order
          return unless order
          return if order.any? { |e| e.name == name }

          Ooxml::ElementOrder.insert_at(
            obj, position, Lutaml::Xml::Element.new("Element", name,
                                                    node_type: :element)
          )
        end

        # -- Run utilities (delegate to RunUtils) --

        def empty_run?(run)
          Builder::RunUtils.empty_run?(run)
        end

        def strip_empty_runs(paragraph)
          before = paragraph.runs.size
          paragraph.runs.reject! { |r| empty_run?(r) }
          removed = before - paragraph.runs.size
          return unless removed.positive?

          record_fix(FixCodes::EMPTY_RUNS_STRIPPED,
                     "Stripped #{removed} empty run(s) from " \
                     "#{paragraph.class.name.split('::').last}")
        end

        def strip_empty_runs_from_notes(entries)
          entries.each do |entry|
            entry.paragraphs.each { |p| strip_empty_runs(p) }
          end
        end

        # Shared paragraph backfill: assign rsid, paraId, textId defaults.
        def backfill_paragraphs(paragraphs, rsid, id_seed)
          paragraphs.each_with_index do |para, idx|
            strip_empty_runs(para)
            para.rsid_r ||= rsid
            para.rsid_r_default ||= "00000000"
            para.para_id ||= generate_hex_id("#{id_seed}:#{idx}")
            para.text_id ||= "77777777"
          end
        end

        # Merge adjacent runs with identical formatting and consolidate
        # standalone tab/br runs into following text runs (F4 + F5).
        # Respects element_order: only merges runs that are truly adjacent
        # in document order (not separated by hyperlinks, bookmarks, etc.).
        def consolidate_runs(paragraph)
          runs = paragraph.runs
          return if runs.nil? || runs.size < 2

          run_indices = adjacent_run_indices(paragraph)
          merged = [runs.first]
          runs[1..].each_with_index do |run, idx|
            prev = merged.last
            if run_indices.include?(idx) &&
               run_properties_match?(prev, run) && can_merge?(prev, run)
              merge_run_into(prev, run)
            else
              merged << run
            end
          end

          paragraph.runs = merged
        end

        # Returns the set of run indices (0-based into runs[1..]) where
        # the run at that index is immediately preceded by another run
        # in element_order (no non-run elements between them).
        def adjacent_run_indices(paragraph)
          eo = paragraph.element_order
          return (0...paragraph.runs.size - 1).to_a unless eo && !eo.empty?

          indices = Set.new
          run_count = 0
          prev_was_run = false
          eo.each do |entry|
            if entry.name == "r"
              if prev_was_run
                indices << (run_count - 1)
              end
              run_count += 1
              prev_was_run = true
            else
              prev_was_run = false
            end
          end
          indices
        end

        def consolidate_runs_in_body(body)
          walk_body_paragraphs(body) { |p| consolidate_runs(p) }
        end

        # -- YAML config --

        CONFIG_DIR = File.join(__dir__, "../../../../config")

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

        # -- mc:Ignorable helpers --

        def set_mc_ignorable(model, prefixes: EXTENSION_PREFIXES)
          model.mc_ignorable = Ooxml::Types::McIgnorable.new(prefixes)
        end

        # -- Relationship builders --

        def build_rel(id, type, target, target_mode: nil)
          attrs = { id: id, type: type, target: target }
          attrs[:target_mode] = target_mode if target_mode
          Ooxml::Relationships::Relationship.new(**attrs)
        end

        def run_properties_match?(a, b)
          Builder::RunUtils.properties_match?(a, b)
        end

        def can_merge?(prev, current)
          Builder::RunUtils.text_only_run?(prev) &&
            Builder::RunUtils.text_only_run?(current)
        end

        def text_only_run?(run)
          Builder::RunUtils.text_only_run?(run)
        end

        def merge_run_into(target, source)
          Builder::RunUtils.merge_text(target, source)

          target.tab ||= source.tab
          target.break ||= source.break
          target.position_tab ||= source.position_tab
          target.no_break_hyphen ||= source.no_break_hyphen
          target.del_text ||= source.del_text
        end

        # -- Note-type dispatch --
        #
        # Single source of truth for :footnote/:endnote discrimination.
        # Adding a third note type means editing only these helpers.

        def notes_collection_for(type)
          case type
          when :footnote then package.footnotes
          when :endnote  then package.endnotes
          end
        end

        # Package part path of the notes collection for the note type.
        def notes_part_for(type)
          case type
          when :footnote then "word/footnotes.xml"
          when :endnote  then "word/endnotes.xml"
          end
        end

        def note_entries_for(notes, type)
          return [] unless notes

          case type
          when :footnote then notes.footnote_entries
          when :endnote  then notes.endnote_entries
          end
        end

        def note_reference_from_run(run, type)
          case type
          when :footnote then run.footnote_reference
          when :endnote  then run.endnote_reference
          end
        end

        def build_notes_collection(type, entries:)
          case type
          when :footnote then Wordprocessingml::Footnotes.new(footnote_entries: entries)
          when :endnote  then Wordprocessingml::Endnotes.new(endnote_entries: entries)
          end
        end

        def assign_note_pr(settings, type)
          case type
          when :footnote then settings.footnote_pr = Wordprocessingml::FootnotePr.new
          when :endnote  then settings.endnote_pr = Wordprocessingml::EndnotePr.new
          end
        end

        def set_notes_collection(notes, type)
          case type
          when :footnote then package.footnotes = notes
          when :endnote  then package.endnotes = notes
          end
        end
      end
    end
  end
end
