# frozen_string_literal: true

require "json"

module Uniword
  module Spellcheck
    # Holds spell and grammar check results.
    #
    # Responsibility: Collect and report spellcheck findings.
    # Single Responsibility - only manages result storage and output.
    #
    # @example Build and query results
    #   result = SpellcheckResult.new
    #   result.add_misspelling(word: "teh", position: 5,
    #     suggestions: ["the", "tea"])
    #   result.add_grammar_issue(message: "Double space", position: 12)
    #   result.clean?  #=> false
    class SpellcheckResult
      attr_reader :misspellings, :grammar_issues

      # Initialize an empty result set.
      def initialize
        @misspellings = []
        @grammar_issues = []
      end

      # Add a misspelling.
      #
      # @param word [String] The misspelled word
      # @param position [Integer] Character position in document text
      # @param suggestions [Array<String>] Suggested corrections
      # @return [void]
      def add_misspelling(word:, position:, suggestions: [])
        @misspellings << {
          word: word,
          position: position,
          suggestions: suggestions,
        }
      end

      # Add a grammar issue.
      #
      # @param message [String] Description of the issue
      # @param position [Integer] Character position in document text
      # @param context [String, nil] Surrounding text for context
      # @return [void]
      def add_grammar_issue(message:, position:, context: nil)
        @grammar_issues << {
          message: message,
          position: position,
          context: context,
        }
      end

      # Whether no issues were found.
      #
      # @return [Boolean] true if no misspellings or grammar issues
      def clean?
        @misspellings.empty? && @grammar_issues.empty?
      end

      # Total number of issues found.
      #
      # @return [Integer] Combined count
      def issue_count
        @misspellings.size + @grammar_issues.size
      end

      # Serialize results to JSON.
      #
      # @return [String] JSON representation
      def to_json(*_args)
        JSON.pretty_generate(
          misspellings: misspellings,
          grammar_issues: grammar_issues,
          issue_count: issue_count,
          clean: clean?,
        )
      end
    end
  end
end
