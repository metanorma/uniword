# frozen_string_literal: true

module Uniword
  module FindReplace
    # Literal substring matcher. Replaces every non-overlapping
    # occurrence of `pattern` with `replacement`.
    class StringMatcher < Matcher
      # @param pattern [String] literal substring to find
      # @param replacement [String] replacement text
      # @param ignore_case [Boolean] match case-insensitively
      def initialize(pattern:, replacement:, ignore_case: false)
        raise ArgumentError, "pattern cannot be empty" if pattern.empty?

        @pattern = pattern
        @replacement = replacement
        @ignore_case = ignore_case
      end

      # @param text [String]
      # @return [Array(String, Integer)]
      def apply(text)
        unless text.include?(@pattern) || matches_ignore_case?(text)
          return [text,
                  0]
        end

        text.size
        result = replace_all(text)
        substitutions = count_substitutions(text, result)
        [result, substitutions]
      end

      private

      def matches_ignore_case?(text)
        @ignore_case && text.downcase.include?(@pattern.downcase)
      end

      def replace_all(text)
        if @ignore_case
          pattern = /#{Regexp.escape(@pattern)}/i
          text.gsub(pattern, @replacement)
        else
          text.gsub(@pattern, @replacement)
        end
      end

      # Net change in match count from the substitution. Computed by
      # walking the original text and counting non-overlapping
      # matches; the gsub above cannot be relied on directly when
      # ignore_case is on (the pattern escapes are regex-based).
      def count_substitutions(original, _replacement)
        pattern = @ignore_case ? /#{Regexp.escape(@pattern)}/i : nil
        if @ignore_case
          original.scan(pattern).size
        else
          count_literal(original)
        end
      end

      def count_literal(text)
        count = 0
        idx = 0
        while (idx = text.index(@pattern, idx))
          count += 1
          idx += @pattern.length
        end
        count
      end
    end
  end
end
