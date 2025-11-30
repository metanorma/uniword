# frozen_string_literal: true

require_relative 'metadata'
require_relative '../configuration/configuration_loader'

module Uniword
  module Metadata
    # Validates metadata against schema.
    #
    # Responsibility: Validate metadata against schema rules.
    # Single Responsibility: Only handles metadata validation.
    #
    # The MetadataValidator:
    # - Validates field types (string, integer, array, etc.)
    # - Validates field constraints (required, max_length, etc.)
    # - Validates field values (allowed_values, pattern, etc.)
    # - Validates dependencies between fields
    # - Returns detailed validation errors
    #
    # Does NOT handle: Extraction, updating, or indexing.
    # Those responsibilities belong to separate classes.
    #
    # @example Validate metadata
    #   validator = MetadataValidator.new
    #   result = validator.validate(metadata)
    #   puts "Valid: #{result[:valid]}"
    #   puts "Errors: #{result[:errors]}"
    #
    # @example Validate for specific scenario
    #   result = validator.validate(metadata, scenario: :publication)
    class MetadataValidator
      # @return [Hash] Loaded schema configuration
      attr_reader :schema

      # Initialize a new MetadataValidator.
      #
      # @param config_file [String] Path to schema configuration
      #
      # @example Create validator
      #   validator = MetadataValidator.new
      #
      # @example Custom schema
      #   validator = MetadataValidator.new(
      #     config_file: 'config/custom_schema.yml'
      #   )
      def initialize(config_file: 'metadata_schema')
        @schema = load_schema(config_file)
      end

      # Validate metadata against schema.
      #
      # @param metadata [Metadata, Hash] Metadata to validate
      # @param scenario [Symbol, nil] Validation scenario (:publication, :archival)
      # @return [Hash] Validation result with :valid and :errors keys
      #
      # @example Validate metadata
      #   result = validator.validate(metadata)
      #   if result[:valid]
      #     puts "Valid!"
      #   else
      #     puts "Errors: #{result[:errors].join(', ')}"
      #   end
      def validate(metadata, scenario: nil)
        meta = metadata.is_a?(Metadata) ? metadata : Metadata.new(metadata)
        errors = []

        # Validate field types and constraints
        validate_core_properties(meta, errors)
        validate_extended_properties(meta, errors)
        validate_statistical_metadata(meta, errors)
        validate_content_metadata(meta, errors)

        # Validate scenario-specific requirements
        validate_scenario_requirements(meta, scenario, errors) if scenario

        # Validate field dependencies
        validate_dependencies(meta, errors)

        {
          valid: errors.empty?,
          errors: errors
        }
      end

      # Check if metadata is valid.
      #
      # @param metadata [Metadata, Hash] Metadata to validate
      # @param scenario [Symbol, nil] Validation scenario
      # @return [Boolean] true if valid
      #
      # @example Check validity
      #   valid = validator.valid?(metadata)
      def valid?(metadata, scenario: nil)
        validate(metadata, scenario: scenario)[:valid]
      end

      # Get validation errors for metadata.
      #
      # @param metadata [Metadata, Hash] Metadata to validate
      # @param scenario [Symbol, nil] Validation scenario
      # @return [Array<String>] Validation errors
      #
      # @example Get errors
      #   errors = validator.errors(metadata)
      def errors(metadata, scenario: nil)
        validate(metadata, scenario: scenario)[:errors]
      end

      private

      # Load schema from configuration file.
      #
      # @param config_file [String] Configuration file name or path
      # @return [Hash] Loaded schema
      def load_schema(config_file)
        if File.exist?(config_file)
          Configuration::ConfigurationLoader.load_file(config_file)
        else
          Configuration::ConfigurationLoader.load(config_file)
        end
      rescue Configuration::ConfigurationError => e
        warn "Warning: #{e.message}. Using default schema."
        default_schema
      end

      # Get default schema.
      #
      # @return [Hash] Default schema
      def default_schema
        {
          core_properties: {},
          extended_properties: {},
          statistical_metadata: {},
          content_metadata: {}
        }
      end

      # Validate core properties.
      #
      # @param metadata [Metadata] Metadata to validate
      # @param errors [Array] Errors array to populate
      def validate_core_properties(metadata, errors)
        return unless @schema[:core_properties]

        @schema[:core_properties].each do |key, rules|
          validate_field(metadata, key, rules, errors)
        end
      end

      # Validate extended properties.
      #
      # @param metadata [Metadata] Metadata to validate
      # @param errors [Array] Errors array to populate
      def validate_extended_properties(metadata, errors)
        return unless @schema[:extended_properties]

        @schema[:extended_properties].each do |key, rules|
          validate_field(metadata, key, rules, errors)
        end
      end

      # Validate statistical metadata.
      #
      # @param metadata [Metadata] Metadata to validate
      # @param errors [Array] Errors array to populate
      def validate_statistical_metadata(metadata, errors)
        return unless @schema[:statistical_metadata]

        @schema[:statistical_metadata].each do |key, rules|
          validate_field(metadata, key, rules, errors)
        end
      end

      # Validate content metadata.
      #
      # @param metadata [Metadata] Metadata to validate
      # @param errors [Array] Errors array to populate
      def validate_content_metadata(metadata, errors)
        return unless @schema[:content_metadata]

        @schema[:content_metadata].each do |key, rules|
          validate_field(metadata, key, rules, errors)
        end
      end

      # Validate a single field.
      #
      # @param metadata [Metadata] Metadata to validate
      # @param key [Symbol] Field key
      # @param rules [Hash] Validation rules
      # @param errors [Array] Errors array to populate
      def validate_field(metadata, key, rules, errors)
        value = metadata[key]

        # Check required
        if rules[:required] && value.nil?
          errors << "#{key} is required"
          return
        end

        # Skip further validation if value is nil and not required
        return if value.nil?

        # Validate type
        validate_type(key, value, rules[:type], errors)

        # Validate constraints
        validate_constraints(key, value, rules, errors)
      end

      # Validate field type.
      #
      # @param key [Symbol] Field key
      # @param value [Object] Field value
      # @param expected_type [String] Expected type
      # @param errors [Array] Errors array to populate
      def validate_type(key, value, expected_type, errors)
        return unless expected_type

        valid = case expected_type.to_s
                when 'string'
                  value.is_a?(String)
                when 'integer'
                  value.is_a?(Integer)
                when 'float'
                  value.is_a?(Float) || value.is_a?(Integer)
                when 'boolean'
                  value.is_a?(TrueClass) || value.is_a?(FalseClass)
                when 'array'
                  value.is_a?(Array)
                when 'hash'
                  value.is_a?(Hash)
                when 'datetime'
                  value.is_a?(Time) || value.is_a?(DateTime) || value.is_a?(Date)
                else
                  true
                end

        return if valid

        errors << "#{key} must be of type #{expected_type}, got #{value.class}"
      end

      # Validate field constraints.
      #
      # @param key [Symbol] Field key
      # @param value [Object] Field value
      # @param rules [Hash] Validation rules
      # @param errors [Array] Errors array to populate
      def validate_constraints(key, value, rules, errors)
        # Max length for strings
        if rules[:max_length] && value.is_a?(String) && (value.length > rules[:max_length])
          errors << "#{key} exceeds maximum length of #{rules[:max_length]}"
        end

        # Min/max value for numbers
        if rules[:min_value] && value.is_a?(Numeric) && (value < rules[:min_value])
          errors << "#{key} must be at least #{rules[:min_value]}"
        end

        if rules[:max_value] && value.is_a?(Numeric) && (value > rules[:max_value])
          errors << "#{key} cannot exceed #{rules[:max_value]}"
        end

        # Max items for arrays
        if rules[:max_items] && value.is_a?(Array) && (value.size > rules[:max_items])
          errors << "#{key} exceeds maximum of #{rules[:max_items]} items"
        end

        # Allowed values
        if rules[:allowed_values] && !rules[:allowed_values].include?(value)
          errors << "#{key} must be one of: #{rules[:allowed_values].join(', ')}"
        end

        # Pattern matching for strings
        return unless rules[:pattern] && value.is_a?(String)
        return if value.match?(Regexp.new(rules[:pattern]))

        errors << "#{key} does not match required pattern"
      end

      # Validate scenario-specific requirements.
      #
      # @param metadata [Metadata] Metadata to validate
      # @param scenario [Symbol] Validation scenario
      # @param errors [Array] Errors array to populate
      def validate_scenario_requirements(metadata, scenario, errors)
        return unless @schema[:validation_rules]

        scenario_key = :"required_for_#{scenario}"
        required_fields = @schema[:validation_rules][scenario_key]
        return unless required_fields

        required_fields.each do |field|
          field_key = field.to_sym
          errors << "#{field_key} is required for #{scenario}" if metadata[field_key].nil?
        end
      end

      # Validate field dependencies.
      #
      # @param metadata [Metadata] Metadata to validate
      # @param errors [Array] Errors array to populate
      def validate_dependencies(metadata, errors)
        return unless @schema[:validation_rules]
        return unless @schema[:validation_rules][:dependencies]

        @schema[:validation_rules][:dependencies].each do |field, conditions|
          field_value = metadata[field]
          next unless field_value

          conditions.each do |value, requirements|
            next unless field_value.to_s == value.to_s

            required_fields = requirements[:requires] || []
            required_fields.each do |req_field|
              req_key = req_field.to_sym
              if metadata[req_key].nil?
                errors << "#{req_field} is required when #{field} is '#{value}'"
              end
            end
          end
        end
      end
    end
  end
end
