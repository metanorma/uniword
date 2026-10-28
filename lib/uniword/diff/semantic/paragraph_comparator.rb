# frozen_string_literal: true

module Uniword
  module Diff
    module Semantic
      # LCS-based paragraph comparator. Aligns old and new paragraph
      # lists with a proper dynamic-programming LCS, classifies each
      # aligned pair, and emits changes for any pair that isn't
      # :unchanged.
      #
      # Reuses the paragraph text via `Paragraph#text`.
      module ParagraphComparator
        module_function

        # @param old_paras [Array<Wordprocessingml::Paragraph>]
        # @param new_paras [Array<Wordprocessingml::Paragraph>]
        # @yieldparam change [Change]
        # @return [void]
        def each_change(old_paras, new_paras, &block)
          old_paras ||= []
          new_paras ||= []
          old_keys = old_paras.map { |p| fingerprint(p) }
          new_keys = new_paras.map { |p| fingerprint(p) }
          alignment = align(old_keys, new_keys)

          emit_changes(alignment, old_paras, new_paras, &block)
        end

        # Stable text fingerprint for one paragraph. Identical text
        # produces identical fingerprints.
        #
        # @param paragraph [Wordprocessingml::Paragraph]
        # @return [String]
        def fingerprint(paragraph)
          (paragraph&.text || "").to_s
        end

        # DP LCS alignment of two arrays of fingerprints. Returns a
        # list of `[old_idx, new_idx]` pairs:
        #   - matching pair `[i, j]` when keys are equal
        #   - `[i, nil]` when old[i] is removed
        #   - `[nil, j]` when new[j] is added
        #
        # @param old_keys [Array<String>]
        # @param new_keys [Array<String>]
        # @return [Array<Array(Integer, Integer)>]
        def align(old_keys, new_keys)
          lcs_pairs = lcs_match_pairs(old_keys, new_keys)
          pairs = []
          i = 0
          j = 0
          lcs_pairs.each do |mi, mj|
            while i < mi
              pairs << [i, nil]
              i += 1
            end
            while j < mj
              pairs << [nil, j]
              j += 1
            end
            pairs << [mi, mj]
            i = mi + 1
            j = mj + 1
          end
          while i < old_keys.length
            pairs << [i, nil]
            i += 1
          end
          while j < new_keys.length
            pairs << [nil, j]
            j += 1
          end
          pairs
        end

        # DP LCS: returns the list of matching (i, j) pairs in order.
        #
        # @param a [Array<String>]
        # @param b [Array<String>]
        # @return [Array<Array(Integer, Integer)>]
        def lcs_match_pairs(a, b)
          n = a.length
          m = b.length
          dp = Array.new(n + 1) { Array.new(m + 1, 0) }
          (1..n).each do |i|
            (1..m).each do |j|
              dp[i][j] = if a[i - 1] == b[j - 1]
                           dp[i - 1][j - 1] + 1
                         else
                           [dp[i - 1][j], dp[i][j - 1]].max
                         end
            end
          end
          backtrack(dp, a, b, n, m)
        end

        # Backtrack through the DP table to recover matching pairs.
        def backtrack(dp, a, b, i, j)
          return [] if i.zero? || j.zero?

          if a[i - 1] == b[j - 1]
            backtrack(dp, a, b, i - 1, j - 1) << [i - 1, j - 1]
          elsif dp[i - 1][j] >= dp[i][j - 1]
            backtrack(dp, a, b, i - 1, j)
          else
            backtrack(dp, a, b, i, j - 1)
          end
        end

        def emit_changes(alignment, old_paras, new_paras)
          collapsed = collapse_remove_add_pairs(alignment)
          collapsed.each do |old_idx, new_idx|
            case [old_idx.nil?, new_idx.nil?]
            when [true, false]
              yield Change.new(kind: :added, new_index: new_idx,
                               description: "Paragraph #{new_idx + 1} added")
            when [false, true]
              yield Change.new(kind: :removed, old_index: old_idx,
                               description: "Paragraph #{old_idx + 1} removed")
            when [false, false]
              next if identical?(old_paras[old_idx], new_paras[new_idx])

              yield classify_modified(old_paras[old_idx],
                                      new_paras[new_idx],
                                      old_idx, new_idx)
            end
          end
        end

        # Collapse adjacent `[i, nil], [nil, j]` pairs into `[i, j]`
        # modified pairs. Without this, text edits show as one remove
        # + one add instead of one modification.
        #
        # @param alignment [Array<Array(Integer, Integer)>]
        # @return [Array<Array(Integer, Integer)>]
        def collapse_remove_add_pairs(alignment)
          result = []
          i = 0
          while i < alignment.length
            curr = alignment[i]
            nxt = alignment[i + 1]
            if curr[0] && curr[1].nil? && nxt && nxt[0].nil? && nxt[1]
              result << [curr[0], nxt[1]]
              i += 2
            else
              result << curr
              i += 1
            end
          end
          result
        end

        # Two paragraphs are identical when their full XML is byte-
        # equal — same text AND same formatting AND same structure.
        def identical?(old_para, new_para)
          old_para.to_xml == new_para.to_xml
        end

        # Classify a modified pair by what changed.
        def classify_modified(old_para, new_para, old_idx, new_idx)
          modifier = modifier_for(old_para, new_para)
          Change.new(
            kind: :modified,
            modifier: modifier,
            old_index: old_idx,
            new_index: new_idx,
            description: "Paragraph #{old_idx + 1} -> #{new_idx + 1} " \
                         "(#{modifier})",
          )
        end

        # Decide what changed between two paragraphs with the same
        # text but different XML.
        def modifier_for(old_para, new_para)
          return :text if old_para.text != new_para.text

          old_xml = old_para.to_xml
          new_xml = new_para.to_xml
          return :format if format_only_change?(old_xml, new_xml)

          :structure
        end

        # Heuristic: a format-only change alters rPr but not run
        # structure. True when removing all `<w:rPr>...</w:rPr>`
        # blocks equalizes the XML.
        def format_only_change?(old_xml, new_xml)
          stripped_old = old_xml.gsub(%r{<w:rPr>.*?</w:rPr>}m, "")
          stripped_new = new_xml.gsub(%r{<w:rPr>.*?</w:rPr>}m, "")
          stripped_old == stripped_new
        end
      end
    end
  end
end
