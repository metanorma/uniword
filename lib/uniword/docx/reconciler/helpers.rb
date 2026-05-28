# frozen_string_literal: true

require "digest"
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
              texts << (para.runs || []).map { |r| r.text.to_s }.join
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

        def walk_table_paragraphs(table)
          return unless table
          table.rows&.each do |row|
            row.cells&.each do |cell|
              cell.paragraphs.each { |p| yield p }
            end
          end
        end

        # -- Element order --

        def ensure_element_in_order(model, tag_name, after: nil, before: nil)
          order = model.element_order
          return unless order

          return if order.any? { |e| e.name == tag_name }

          entry = Lutaml::Xml::Element.new("Element", tag_name)

          if after
            idx = order.index { |e| e.name == after }
            thaw_and_insert(model, order, idx ? idx + 1 : order.size, entry)
          elsif before
            idx = order.index { |e| e.name == before }
            thaw_and_insert(model, order, idx || 0, entry)
          else
            thaw_and_append(model, order, entry)
          end
        end

        def insert_element_order(obj, name, position)
          order = obj.element_order
          return unless order

          return if order.any? { |e| e.name == name }

          entry = Lutaml::Xml::Element.new("Element", name, node_type: :element)
          thaw_and_insert(obj, order, position, entry)
        end

        private

        # lutaml-model freezes element_order after XML parsing.
        # Replace the frozen array with a mutable copy when modification is needed.
        def thaw_and_insert(model, order, position, entry)
          model.element_order = order.dup.insert(position, entry)
        end

        def thaw_and_append(model, order, entry)
          model.element_order = order.dup << entry
        end

        # -- Run utilities --

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

        def strip_empty_runs(paragraph)
          removed = paragraph.runs.reject! { |r| empty_run?(r) }
          return unless removed && !removed.empty?

          record_fix("R10",
                     "Stripped #{removed.size} empty run(s) from " \
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
        def consolidate_runs(paragraph)
          runs = paragraph.runs
          return if runs.nil? || runs.size < 2

          merged = [runs.first]
          runs[1..].each do |run|
            prev = merged.last
            if run_properties_match?(prev, run) && can_merge?(prev, run)
              merge_run_into(prev, run)
            else
              merged << run
            end
          end

          paragraph.runs = merged
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

        # -- Relationship builders --

        def build_rel(id, type, target, target_mode: nil)
          attrs = { id: id, type: type, target: target }
          attrs[:target_mode] = target_mode if target_mode
          Ooxml::Relationships::Relationship.new(**attrs)
        end

        def run_properties_match?(a, b)
          rpr_a = a.properties
          rpr_b = b.properties
          return true if rpr_a.nil? && rpr_b.nil?
          return false if rpr_a.nil? || rpr_b.nil?

          rpr_a.to_xml == rpr_b.to_xml
        end

        def can_merge?(prev, current)
          return false unless text_only_run?(prev) && text_only_run?(current)
          true
        end

        def text_only_run?(run)
          return false if run.drawings&.any?
          return false if run.pictures&.any?
          return false if run.alternate_content
          return false if run.footnote_reference
          return false if run.endnote_reference
          return false if run.field_char
          return false if run.instr_text
          return false if run.sym
          true
        end

        def merge_run_into(target, source)
          if source.text
            existing = target.text&.to_s.to_s
            appended = source.text.to_s
            combined = existing + appended
            new_text = Wordprocessingml::Text.new(content: combined)
            if Wordprocessingml::Text.preserve_whitespace?(combined)
              new_text.xml_space = "preserve"
            end
            target.text = new_text
          end

          target.tab ||= source.tab
          target.break ||= source.break
          target.position_tab ||= source.position_tab
          target.no_break_hyphen ||= source.no_break_hyphen
          target.del_text ||= source.del_text
        end
      end
    end
  end
end
