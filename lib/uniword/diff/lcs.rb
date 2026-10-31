# frozen_string_literal: true

module Uniword
  module Diff
    # Longest-common-subsequence alignment over sequences.
    #
    # Shared substrate for the differ (paragraph alignment) and the
    # redliner (paragraph and word-token alignment). Sequences are
    # compared by element equality, so both operate on plain strings.
    module Lcs
      # Matched (old_index, new_index) pairs, ascending.
      #
      # @param old_seq [Array] base sequence
      # @param new_seq [Array] revised sequence
      # @return [Array<Array(Integer, Integer)>]
      def self.pairs(old_seq, new_seq)
        m = old_seq.size
        n = new_seq.size

        dp = Array.new(m + 1) { Array.new(n + 1, 0) }
        (1..m).each do |i|
          (1..n).each do |j|
            dp[i][j] = if old_seq[i - 1] == new_seq[j - 1]
                         dp[i - 1][j - 1] + 1
                       else
                         [dp[i - 1][j], dp[i][j - 1]].max
                       end
          end
        end

        matches = []
        i = m
        j = n
        while i.positive? && j.positive?
          if old_seq[i - 1] == new_seq[j - 1]
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

      # Alignment walk over two sequences.
      #
      # Returns tuples [action, old_index, new_index] in document
      # order, where action is :kept or :modified (both indexes set),
      # :removed (old only), or :added (new only).
      #
      # @param old_seq [Array]
      # @param new_seq [Array]
      # @return [Array<Array(Symbol, Integer, Integer)>]
      def self.alignment(old_seq, new_seq)
        lcs = pairs(old_seq, new_seq)

        result = []
        old_i = 0
        new_i = 0
        lcs_idx = 0

        while old_i < old_seq.size || new_i < new_seq.size
          old_in_lcs = lcs_idx < lcs.size &&
            lcs[lcs_idx][0] == old_i
          new_in_lcs = lcs_idx < lcs.size &&
            lcs[lcs_idx][1] == new_i

          if old_in_lcs && new_in_lcs
            action = old_seq[old_i] == new_seq[new_i] ? :kept : :modified
            result << [action, old_i, new_i]
            old_i += 1
            new_i += 1
            lcs_idx += 1
          elsif old_in_lcs
            result << [:added, nil, new_i]
            new_i += 1
          elsif new_in_lcs
            result << [:removed, old_i, nil]
            old_i += 1
          elsif old_i < old_seq.size && new_i < new_seq.size
            result << [:modified, old_i, new_i]
            old_i += 1
            new_i += 1
          elsif old_i < old_seq.size
            result << [:removed, old_i, nil]
            old_i += 1
          else
            result << [:added, nil, new_i]
            new_i += 1
          end
        end

        result
      end
    end
  end
end
