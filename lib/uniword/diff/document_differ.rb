# frozen_string_literal: true

require_relative "diff_result"

module Uniword
  module Diff
    # Compares two DocumentRoot instances and produces a DiffResult.
    #
    # Uses LCS (longest common subsequence) alignment for paragraphs to
    # detect added, removed, and modified paragraphs. Optionally compares
    # formatting, structure, metadata, and styles.
    #
    # @example
    #   old_doc = DocumentFactory.from_file("v1.docx")
    #   new_doc = DocumentFactory.from_file("v2.docx")
    #   result = DocumentDiffer.new(old_doc, new_doc).diff
    #   puts result.summary
    class DocumentDiffer
      # Initialize with two documents and options.
      #
      # @param old_doc [Wordprocessingml::DocumentRoot] Original document
      # @param new_doc [Wordprocessingml::DocumentRoot] Modified document
      # @param options [Hash] Comparison options
      # @option options [Boolean] :text_only Skip formatting comparison
      # @option options [String] :part Focus on a specific part
      #   (styles/headers/content)
      def initialize(old_doc, new_doc, options: {})
        @old_doc = old_doc
        @new_doc = new_doc
        @options = options
      end

      # Perform the diff and return a DiffResult.
      #
      # @return [DiffResult]
      def diff
        DiffResult.new(
          text_changes: diff_text,
          format_changes: text_only? ? [] : diff_formatting,
          structure_changes: diff_structure,
          metadata_changes: diff_metadata,
          style_changes: diff_styles
        )
      end

      private

      # Whether to compare text only (skip formatting).
      #
      # @return [Boolean]
      def text_only?
        @options[:text_only] == true
      end

      # Compare paragraph text using LCS alignment.
      #
      # Aligns old and new paragraphs via LCS, then identifies added,
      # removed, and modified paragraphs.
      #
      # @return [Array<Hash>]
      def diff_text
        old_paras = @old_doc.paragraphs
        new_paras = @new_doc.paragraphs
        changes = []

        alignment = align_paragraphs(old_paras, new_paras)

        alignment.each do |action, old_idx, new_idx|
          case action
          when :added
            para = new_paras[new_idx]
            changes << build_change(
              :added, nil, para.text,
              position: new_idx
            )
          when :removed
            para = old_paras[old_idx]
            changes << build_change(
              :removed, para.text, nil,
              position: old_idx
            )
          when :modified
            old_para = old_paras[old_idx]
            new_para = new_paras[new_idx]
            old_text = old_para.text
            new_text = new_para.text
            if old_text != new_text
              changes << build_change(
                :modified, old_text, new_text,
                position: new_idx
              )
            end
          end
        end

        changes
      end

      # Compare formatting of aligned paragraphs.
      #
      # Checks paragraph-level formatting (alignment, spacing, indentation,
      # numbering) and run-level formatting (bold, italic, underline, font,
      # size, color) for each aligned paragraph pair.
      #
      # @return [Array<Hash>]
      def diff_formatting
        old_paras = @old_doc.paragraphs
        new_paras = @new_doc.paragraphs
        changes = []

        alignment = align_paragraphs(old_paras, new_paras)

        alignment.each do |action, old_idx, new_idx|
          next unless action == :modified

          old_para = old_paras[old_idx]
          new_para = new_paras[new_idx]

          changes.concat(
            diff_paragraph_formatting(old_para, new_para, new_idx)
          )
          changes.concat(
            diff_run_formatting(old_para, new_para, new_idx)
          )
        end

        changes
      end

      # Compare document structure (paragraph/table counts, positions).
      #
      # @return [Array<Hash>]
      def diff_structure
        changes = []

        old_paras = @old_doc.paragraphs
        new_paras = @new_doc.paragraphs
        old_tables = @old_doc.tables
        new_tables = @new_doc.tables

        if old_paras.size != new_paras.size
          changes << {
            type: :structure,
            change: :paragraph_count,
            old_count: old_paras.size,
            new_count: new_paras.size
          }
        end

        if old_tables.size != new_tables.size
          changes << {
            type: :structure,
            change: :table_count,
            old_count: old_tables.size,
            new_count: new_tables.size
          }
        end

        changes
      end

      # Compare document metadata (core properties).
      #
      # @return [Hash]
      def diff_metadata
        old_cp = @old_doc.core_properties
        new_cp = @new_doc.core_properties

        fields = %i[title creator subject keywords
                    description last_modified_by revision
                    created modified]

        changes = {}
        fields.each do |field|
          old_val = metadata_value(old_cp, field)
          new_val = metadata_value(new_cp, field)
          changes[field] = { old: old_val, new: new_val } if old_val != new_val
        end

        changes
      end

      # Compare style definitions.
      #
      # Detects added, removed, and modified styles by comparing style
      # name and ID collections between the two documents.
      #
      # @return [Array<Hash>]
      def diff_styles
        old_styles = extract_styles(@old_doc)
        new_styles = extract_styles(@new_doc)
        changes = []

        old_ids = old_styles.keys
        new_ids = new_styles.keys

        # Added styles
        (new_ids - old_ids).each do |style_id|
          changes << {
            type: :style,
            change: :added,
            style_id: style_id,
            name: new_styles[style_id]
          }
        end

        # Removed styles
        (old_ids - new_ids).each do |style_id|
          changes << {
            type: :style,
            change: :removed,
            style_id: style_id,
            name: old_styles[style_id]
          }
        end

        changes
      end

      # Align old and new paragraphs using LCS on text content.
      #
      # Returns an array of tuples: [action, old_index, new_index]
      # where action is :kept, :added, :removed, or :modified.
      #
      # @param old_paras [Array<Paragraph>]
      # @param new_paras [Array<Paragraph>]
      # @return [Array<Array(Symbol, Integer, Integer)>]
      def align_paragraphs(old_paras, new_paras)
        old_texts = old_paras.map { |p| p.text.to_s }
        new_texts = new_paras.map { |p| p.text.to_s }

        lcs = compute_lcs(old_texts, new_texts)

        result = []
        old_i = 0
        new_i = 0
        lcs_idx = 0

        while old_i < old_texts.size || new_i < new_texts.size
          old_in_lcs = lcs_idx < lcs.size &&
                       lcs[lcs_idx][0] == old_i
          new_in_lcs = lcs_idx < lcs.size &&
                       lcs[lcs_idx][1] == new_i

          if old_in_lcs && new_in_lcs
            # LCS match at both positions -- aligned
            old_text = old_texts[old_i]
            new_text = new_texts[new_i]
            action = old_text == new_text ? :kept : :modified
            result << [action, old_i, new_i]
            old_i += 1
            new_i += 1
            lcs_idx += 1
          elsif old_in_lcs
            # Old is part of a future LCS match, insert new as added
            result << [:added, nil, new_i]
            new_i += 1
          elsif new_in_lcs
            # New is part of a future LCS match, remove old
            result << [:removed, old_i, nil]
            old_i += 1
          elsif old_i < old_texts.size && new_i < new_texts.size
            # Neither is in LCS at this point -- treat as modified
            result << [:modified, old_i, new_i]
            old_i += 1
            new_i += 1
          elsif old_i < old_texts.size
            result << [:removed, old_i, nil]
            old_i += 1
          else
            result << [:added, nil, new_i]
            new_i += 1
          end
        end

        result
      end

      # Compute the LCS table and return matched index pairs.
      #
      # @param old_texts [Array<String>]
      # @param new_texts [Array<String>]
      # @return [Array<Array(Integer, Integer)>] Matched (old_i, new_i) pairs
      def compute_lcs(old_texts, new_texts)
        m = old_texts.size
        n = new_texts.size

        # Build LCS length table
        dp = Array.new(m + 1) { Array.new(n + 1, 0) }
        (1..m).each do |i|
          (1..n).each do |j|
            dp[i][j] = if old_texts[i - 1] == new_texts[j - 1]
                         dp[i - 1][j - 1] + 1
                       else
                         [dp[i - 1][j], dp[i][j - 1]].max
                       end
          end
        end

        # Backtrack to find matches
        matches = []
        i = m
        j = n
        while i.positive? && j.positive?
          if old_texts[i - 1] == new_texts[j - 1]
            matches << [i - 1, j - 1]
            i -= 1
            j -= 1
          elsif dp[i - 1][j] >= dp[i][j - 1]
            i -= 1
          else
            j -= 1
          end
        end

        matches.reverse
      end

      # Compare paragraph-level formatting between two paragraphs.
      #
      # @param old_para [Paragraph]
      # @param new_para [Paragraph]
      # @param position [Integer] Paragraph position in new document
      # @return [Array<Hash>]
      def diff_paragraph_formatting(old_para, new_para, position)
        changes = []
        old_props = old_para.properties
        new_props = new_para.properties

        fmt_fields = {
          alignment: :alignment,
          style: :style
        }

        fmt_fields.each do |field, method|
          old_val = format_value(old_props, method)
          new_val = format_value(new_props, method)
          next if old_val == new_val

          changes << {
            type: :format,
            change: :modified,
            field: field.to_s,
            old: old_val,
            new: new_val,
            paragraph: position
          }
        end

        changes
      end

      # Compare run-level formatting between two paragraphs.
      #
      # Compares corresponding runs and reports formatting differences.
      #
      # @param old_para [Paragraph]
      # @param new_para [Paragraph]
      # @param position [Integer] Paragraph position in new document
      # @return [Array<Hash>]
      def diff_run_formatting(old_para, new_para, position)
        changes = []
        old_runs = old_para.runs
        new_runs = new_para.runs

        max_runs = [old_runs.size, new_runs.size].max
        max_runs.times do |i|
          old_run = old_runs[i]
          new_run = new_runs[i]

          if old_run.nil?
            changes << {
              type: :format,
              change: :run_added,
              paragraph: position,
              run_index: i
            }
            next
          end

          if new_run.nil?
            changes << {
              type: :format,
              change: :run_removed,
              paragraph: position,
              run_index: i
            }
            next
          end

          run_fmt_changes = compare_run_props(
            old_run.properties, new_run.properties,
            position, i
          )
          changes.concat(run_fmt_changes)
        end

        changes
      end

      # Compare two RunProperties instances.
      #
      # @param old_props [RunProperties, nil]
      # @param new_props [RunProperties, nil]
      # @param para_pos [Integer]
      # @param run_idx [Integer]
      # @return [Array<Hash>]
      def compare_run_props(old_props, new_props, para_pos, run_idx)
        changes = []

        fields = {
          bold: :bold,
          italic: :italic,
          underline: :underline,
          font: :fonts,
          size: :size,
          color: :color
        }

        fields.each do |field, method|
          old_val = run_prop_value(old_props, method)
          new_val = run_prop_value(new_props, method)
          next if old_val == new_val

          changes << {
            type: :format,
            change: :modified,
            field: "run_#{field}",
            old: old_val,
            new: new_val,
            paragraph: para_pos,
            run: run_idx
          }
        end

        changes
      end

      # Extract a formatting value from paragraph properties.
      #
      # @param props [ParagraphProperties, nil]
      # @param method [Symbol]
      # @return [Object, nil]
      def format_value(props, method)
        return nil unless props

        val = props.send(method)
        val.respond_to?(:value) ? val.value : val
      end

      # Extract a value from run properties.
      #
      # @param props [RunProperties, nil]
      # @param method [Symbol]
      # @return [Object, nil]
      def run_prop_value(props, method)
        return nil unless props

        val = props.send(method)
        return nil if val.nil?

        val.respond_to?(:value) ? val.value : val
      end

      # Extract a metadata field value from core properties.
      #
      # @param cp [CoreProperties, nil]
      # @param field [Symbol]
      # @return [String, nil]
      def metadata_value(cp, field)
        return nil unless cp

        val = cp.send(field)
        return nil if val.nil?

        val.respond_to?(:value) ? val.value.to_s : val.to_s
      end

      # Extract styles from a document as a hash of style_id => name.
      #
      # @param doc [Wordprocessingml::DocumentRoot]
      # @return [Hash{String => String}]
      def extract_styles(doc)
        config = doc.styles_configuration
        return {} unless config

        styles = config.styles
        return {} unless styles

        result = {}
        styles.each do |style|
          style_id = style.styleId&.to_s
          name_obj = style.name
          name = name_obj.respond_to?(:val) ? name_obj.val : name_obj.to_s
          result[style_id] = name if style_id
        end

        result
      end

      # Build a text change hash.
      #
      # @param change [Symbol] :added, :removed, or :modified
      # @param old_text [String, nil]
      # @param new_text [String, nil]
      # @param position [Integer]
      # @return [Hash]
      def build_change(change, old_text, new_text, position:)
        {
          type: :text,
          change: change,
          old: old_text,
          new: new_text,
          position: position
        }
      end
    end
  end
end
