# frozen_string_literal: true

module Uniword
  module Accessibility
    module Rules
      # Table Headers Rule - WCAG 1.3.1 Info and Relationships
      #
      # Responsibility: Check that tables have proper headers
      # Single Responsibility: Table header validation only
      #
      # WCAG 1.3.1 Level A: Data tables must have headers
      class TableHeadersRule < AccessibilityRule
        # Check document tables for headers
        #
        # @param document [Document] Document to check
        # @return [Array<AccessibilityViolation>] Found violations
        def check(document)
          violations = []

          document.tables.each_with_index do |table, index|
            # Check if table has header row
            has_header = table.rows.first&.header?

            unless has_header
              violations << create_violation(
                message: "Table #{index + 1} missing header row",
                element: table,
                severity: @config[:severity] || :error,
                suggestion: @config[:suggestion] ||
                  "Mark first row as header: table.rows.first.header = true"
              )
            end

            # Check for caption if required
            next unless @config[:require_caption] && !table_has_caption?(table)

            violations << create_violation(
              message: "Table #{index + 1} missing caption",
              element: table,
              severity: :warning,
              suggestion: "Add table caption to describe the data presented"
            )
          end

          violations
        end

        private

        # Check if table has caption
        #
        # @param table [Table] Table to check
        # @return [Boolean] True if caption exists
        def table_has_caption?(table)
          # Tables may have a caption property or title
          table.respond_to?(:caption) && !table.caption.to_s.strip.empty?
        end
      end
    end
  end
end
