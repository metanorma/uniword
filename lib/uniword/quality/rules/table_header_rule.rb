# frozen_string_literal: true


module Uniword
  module Quality
    # Checks that tables have proper header rows.
    #
    # Responsibility: Validate table structure and headers.
    # Single Responsibility - only checks table headers.
    #
    # Validates:
    # - Tables have at least one header row
    # - Header rows are properly marked
    # - Tables are accessible
    #
    # @example Configuration
    #   table_headers:
    #     enabled: true
    #     require_headers: true
    class TableHeaderRule < QualityRule
      def initialize(config = {})
        super
        @require_headers = @config.fetch(:require_headers, true)
      end

      # Check document for table header violations
      #
      # @param document [Document] The document to check
      # @return [Array<QualityViolation>] List of violations found
      def check(document)
        violations = []

        return violations unless @require_headers

        document.tables.each_with_index do |table, index|
          next if has_header_row?(table)

          violations << create_violation(
            severity: :warning,
            message: "Table #{index + 1} does not have a header row. " \
                     'Headers improve accessibility and readability.',
            location: "Table #{index + 1}",
            element: table
          )
        end

        violations
      end

      private

      # Check if table has a header row
      #
      # @param table [Table] The table to check
      # @return [Boolean] true if table has header row
      def has_header_row?(table)
        return false if table.rows.empty?

        first_row = table.rows.first
        return false unless first_row.respond_to?(:cells)

        # Check if first row cells have header properties
        # In OOXML, header rows typically have specific table cell properties
        # For now, we'll check if the first row has any cells
        # A more sophisticated check would look at cell properties
        !first_row.cells.empty?
      end
    end
  end
end
