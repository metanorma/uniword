# frozen_string_literal: true

require_relative "../report/validation_issue"

module Uniword
  module Validation
    module Rules
      # Base class for all document semantic validation rules.
      #
      # Follows the Open/Closed Principle: new rules can be added by
      # subclassing and registering, without modifying existing code.
      #
      # @example Implement a custom rule
      #   class MyRule < Base
      #     def code = "CUSTOM-001"
      #     def category = :custom
      #     def severity = "warning"
      #
      #     def applicable?(context)
      #       context.part_exists?("word/document.xml")
      #     end
      #
      #     def check(context)
      #       issues = []
      #       # ... validation logic ...
      #       issues
      #     end
      #   end
      #
      #   Uniword::Validation::Rules.register(MyRule)
      class Base
        # Unique code for this rule (e.g., "DOC-020").
        #
        # @return [String]
        def code
          nil
        end

        # Reference to the validity rule in docs/docx-valid/rules/.
        #
        # @return [String, nil] e.g. "R1"
        def validity_rule
          nil
        end

        # Human-readable description of what this rule checks.
        #
        # @return [String, nil]
        def description
          nil
        end

        # Category for grouping (e.g., :styles, :footnotes).
        #
        # @return [Symbol]
        def category
          :general
        end

        # Default severity for issues from this rule.
        #
        # @return [String] "error", "warning", "info", or "notice"
        def severity
          "error"
        end

        # Check if this rule applies to the given document context.
        #
        # @param context [DocumentContext] The document being validated
        # @return [Boolean]
        def applicable?(_context)
          true
        end

        # Run the validation check.
        #
        # @param context [DocumentContext] The document being validated
        # @return [Array<Report::ValidationIssue>]
        def check(_context)
          []
        end

        private

        # Helper to create a ValidationIssue with defaults from the rule.
        def issue(message, part: nil, line: nil, suggestion: nil,
                  severity: nil, code: nil)
          Report::ValidationIssue.new(
            severity: severity || self.severity,
            code: code || self.code,
            message: message,
            part: part,
            line: line,
            suggestion: suggestion,
          )
        end
      end
    end
  end
end
