# frozen_string_literal: true

module Uniword
  module Accessibility
    module Rules
      # Document Title Rule - WCAG 2.4.2 Page Titled
      #
      # Responsibility: Check that document has a descriptive title
      # Single Responsibility: Document title validation only
      #
      # WCAG 2.4.2 Level A: Pages must have titles that describe topic or purpose
      class DocumentTitleRule < AccessibilityRule
        # Check document title
        #
        # @param document [Document] Document to check
        # @return [Array<AccessibilityViolation>] Found violations
        def check(document)
          violations = []

          title = extract_title(document)

          # Check if title exists
          if @config[:require_title] && (title.nil? || title.strip.empty?)
            violations << create_violation(
              message: "Document missing title",
              element: document,
              severity: @config[:severity] || :error,
              suggestion: @config[:suggestion] ||
                "Document must have a descriptive title"
            )
            return violations
          end

          # Check minimum title length
          if title && @config[:min_title_length]
            if title.length < @config[:min_title_length]
              violations << create_violation(
                message: "Document title too short (#{title.length} chars)",
                element: document,
                severity: :warning,
                suggestion: "Title should be descriptive (min #{@config[:min_title_length]} chars)"
              )
            end
          end

          violations
        end

        private

        # Extract title from document
        #
        # @param document [Document] Document to extract from
        # @return [String, nil] Document title
        def extract_title(document)
          # Try to get title from document metadata/properties
          if document.respond_to?(:title)
            document.title
          elsif document.respond_to?(:metadata)
            document.metadata&.title
          end
        end
      end
    end
  end
end