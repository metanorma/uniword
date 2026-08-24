# frozen_string_literal: true

module Uniword
  module FindReplace
    # Regex matcher. Replaces every match of `pattern` with
    # `replacement`, supporting capture-group references (`\1`,
    # `\2`, ...) and `ignore_case`.
    class RegexMatcher < Matcher
      # @param pattern [Regexp, String] pattern to match. String is
      #   compiled to a Regexp.
      # @param replacement [String] replacement, may reference captures
      # @param ignore_case [Boolean] force case-insensitive (only
      #   applies when pattern is a String; Regexp keeps its own flags)
      def initialize(pattern:, replacement:, ignore_case: false)
        @pattern = compile_pattern(pattern, ignore_case)
        @replacement = replacement
      end

      # @param text [String]
      # @return [Array(String, Integer)]
      def apply(text)
        matches = text.scan(@pattern).size
        return [text, 0] if matches.zero?

        [text.gsub(@pattern, @replacement), matches]
      end

      private

      def compile_pattern(pattern, ignore_case)
        return pattern if pattern.is_a?(Regexp)
        return Regexp.new(pattern, Regexp::IGNORECASE) if ignore_case

        Regexp.new(pattern)
      end
    end
  end
end
