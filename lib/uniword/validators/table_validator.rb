# frozen_string_literal: true

# NOTE: element_validator is already loaded by uniword.rb
# No need to require it here to avoid circular dependencies

module Uniword
  module Validators
    # Validator for Table elements
    # Responsibility: Validate table-specific constraints
    #
    # A valid table:
    # - Must be a Table instance
    # - Can have zero or more rows (empty tables are valid)
    # - All rows must be valid TableRow instances
    # - All rows should have consistent column counts (warning, not error)
    # - Properties, if present, must be valid TableProperties
    #
    # @example Using the table validator
    #   validator = Uniword::Validators::TableValidator.new
    #   validator.valid?(table) # => true or false
    #   validator.errors(table) # => ["error message", ...]
    class TableValidator < ElementValidator
      # Validate a table element
      #
      # @param element [Table] The table to validate
      # @return [Boolean] true if valid, false otherwise
      def valid?(element)
        return false unless super
        return false unless element.is_a?(Uniword::Table)

        validate_rows(element) &&
          validate_properties(element)
      end

      # Get validation errors for a table
      #
      # @param element [Table] The table to validate
      # @return [Array<String>] Array of error messages
      def errors(element)
        errors = []

        # Check if element is nil
        return ['Element is nil'] if element.nil?

        # Check table type first (more specific than base check)
        return ['Element must be a Table'] unless element.is_a?(Uniword::Table)

        # Validate rows - collect all specific errors
        errors.concat(row_errors(element))

        # Validate properties - collect all specific errors
        errors.concat(property_errors(element))

        errors
      end

      # Get validation warnings (non-critical issues)
      #
      # @param element [Table] The table to validate
      # @return [Array<String>] Array of warning messages
      def warnings(element)
        warnings = []

        return warnings unless element.is_a?(Uniword::Table)
        return warnings if element.rows.empty?

        # Check for inconsistent column counts
        column_counts = element.rows.map(&:cell_count).uniq
        if column_counts.size > 1
          warnings << "Table has inconsistent column counts: #{column_counts.join(', ')}"
        end

        warnings
      end

      private

      # Validate that all rows are valid TableRow instances
      #
      # @param table [Table] The table to validate
      # @return [Boolean] true if all rows are valid
      def validate_rows(table)
        return true if table.rows.nil? || table.rows.empty?

        table.rows.all? { |row| row.is_a?(Uniword::TableRow) }
      end

      # Get errors related to rows
      #
      # @param table [Table] The table to validate
      # @return [Array<String>] Array of error messages
      def row_errors(table)
        errors = []

        return errors if table.rows.nil? || table.rows.empty?

        table.rows.each_with_index do |row, index|
          unless row.is_a?(Uniword::TableRow)
            errors << "Row at index #{index} must be a TableRow instance"
          end
        end

        errors
      end

      # Validate properties if present
      #
      # @param table [Table] The table to validate
      # @return [Boolean] true if properties are valid or nil
      def validate_properties(table)
        return true if table.properties.nil?

        table.properties.is_a?(Uniword::Properties::TableProperties)
      end

      # Get errors related to properties
      #
      # @param table [Table] The table to validate
      # @return [Array<String>] Array of error messages
      def property_errors(table)
        return [] if table.properties.nil?

        unless table.properties.is_a?(Uniword::Properties::TableProperties)
          return ['Properties must be a TableProperties instance']
        end

        []
      end
    end
  end
end

# Register this validator when the file is loaded
# This ensures the validator is available regardless of load order
if defined?(Uniword::Validators::ElementValidator)
  Uniword::Validators::ElementValidator.register(
    Uniword::Table,
    Uniword::Validators::TableValidator
  )
end
