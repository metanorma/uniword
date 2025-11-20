# frozen_string_literal: true

module Uniword
  module Accessibility
    module Rules
      # Language Specification Rule - WCAG 3.1.1 Language of Page
      #
      # Responsibility: Check that document language is specified
      # Single Responsibility: Language specification validation only
      #
      # WCAG 3.1.1 Level A: Default human language of page can be programmatically determined
      class LanguageSpecificationRule < AccessibilityRule
        # Check document language specification
        #
        # @param document [Document] Document to check
        # @return [Array<AccessibilityViolation>] Found violations
        def check(document)
          violations = []

          return violations unless @config[:require_language]

          language = extract_language(document)

          # Check if language is specified
          if language.nil? || language.strip.empty?
            violations << create_violation(
              message: "Document language not specified",
              element: document,
              severity: @config[:severity] || :error,
              suggestion: @config[:suggestion] ||
                "Set document language property for screen readers"
            )
          end

          violations
        end

        private

        # Extract language from document
        #
        # @param document [Document] Document to extract from
        # @return [String, nil] Document language code
        def extract_language(document)
          # Try to get language from document metadata/properties
          if document.respond_to?(:language)
            document.language
          elsif document.respond_to?(:metadata)
            document.metadata&.language
          end
        end
      end
    end
  end
end