# frozen_string_literal: true

module Uniword
  module Spellcheck
    # Simple rule-based grammar checker.
    #
    # Responsibility: Detect common grammar issues in text using
    # pattern-based rules (no external dependencies).
    #
    # Follows the Open/Closed Principle: new rules can be added by
    # creating new check methods and registering them in #rules.
    #
    # Each rule returns an array of hashes with :message, :position,
    # and :context keys.
    #
    # @example Check a sentence
    #   checker = GrammarChecker.new
    #   issues = checker.check("This is  a test.")
    #   # => [{ message: "Double space detected", position: 8, context: ... }]
    class GrammarChecker
      # Check text for grammar issues using all registered rules.
      #
      # @param text [String] The text to check
      # @return [Array<Hash>] Array of grammar issues
      def check(text)
        return [] if text.nil? || text.strip.empty?

        rules.flat_map { |rule| rule.call(text) }
      end

      private

      # List of rule methods to execute.
      #
      # @return [Array<Proc>] Rule procs that accept text and return issues
      def rules
        [
          method(:check_double_spaces),
          method(:check_repeated_words),
          method(:check_capitalization_after_period)
        ]
      end

      # Detect consecutive double (or more) spaces.
      #
      # @param text [String] The text to check
      # @return [Array<Hash>] Issues found
      def check_double_spaces(text)
        issues = []
        offset = 0

        text.scan(/  +/) do
          pos = Regexp.last_match
                      .offset(0)
          start_pos = pos[0] + offset

          context_start = [start_pos - 10, 0].max
          context_end = [start_pos + 20, text.length].min
          context = text[context_start...context_end]
                    .strip

          issues << {
            message: "Double space detected",
            position: start_pos,
            context: context
          }
        end

        issues
      end

      # Detect repeated consecutive words (case-insensitive).
      #
      # @param text [String] The text to check
      # @return [Array<Hash>] Issues found
      def check_repeated_words(text)
        issues = []

        text.scan(/\b(\w+)\s+\1\b/i) do
          match = Regexp.last_match
          repeated_word = match[1]

          context_start = [match.begin(0) - 15, 0].max
          context_end = [match.end(0) + 15, text.length].min
          context = text[context_start...context_end]
                    .strip

          issues << {
            message: "Repeated word: '#{repeated_word}'",
            position: match.begin(0),
            context: context
          }
        end

        issues
      end

      # Detect missing capitalization after sentence-ending periods.
      #
      # Only flags when the character after ". " is a lowercase letter.
      # Ignores abbreviations (single-letter after period).
      #
      # @param text [String] The text to check
      # @return [Array<Hash>] Issues found
      def check_capitalization_after_period(text)
        issues = []

        text.scan(/\.\s+([a-z])/) do
          match = Regexp.last_match

          # Skip single-character "words" (likely abbreviations)
          char_pos = match.begin(1)
          next_char = text[char_pos + 1]
          next if next_char&.match?(/[a-z]/) &&
                  (char_pos < 2 ||
                   text[char_pos - 2] =~ /[a-z]/)

          context_start = [match.begin(0) - 15, 0].max
          context_end = [match.end(0) + 15, text.length].min
          context = text[context_start...context_end]
                    .strip

          issues << {
            message: "Missing capitalization " \
                     "after period",
            position: match.begin(0),
            context: context
          }
        end

        issues
      end
    end
  end
end
