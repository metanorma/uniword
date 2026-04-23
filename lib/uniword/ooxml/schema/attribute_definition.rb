# frozen_string_literal: true

module Uniword
  module Ooxml
    module Schema
      # Represents the definition of ONE OOXML element attribute.
      #
      # Responsibility: Define schema for a single attribute.
      # Single Responsibility - attribute definition only.
      #
      # Loaded from external YAML schema configuration.
      #
      # @example Create from config
      #   attr_def = AttributeDefinition.new({
      #     name: :val,
      #     type: :enum,
      #     values: ['left', 'right', 'center'],
      #     required: true
      #   })
      class AttributeDefinition
        attr_reader :name, :tag, :type, :required, :values, :namespace,
                    :prefix, :property

        # Initialize attribute definition from configuration
        #
        # @param definition [Hash] Attribute definition hash from YAML
        def initialize(definition)
          @name = definition[:name]&.to_sym
          @tag = definition[:tag] || "w:#{definition[:name]}"
          @type = definition.fetch(:type, :string)&.to_sym
          @required = definition.fetch(:required, false)
          @values = definition[:values] # For enum types
          @namespace = definition[:namespace]
          @prefix = definition[:prefix] || "w"
          @property = definition[:property] # Custom property name mapping
        end

        # Check if attribute is required
        #
        # @return [Boolean] true if required
        def required?
          @required
        end

        # Check if attribute is optional
        #
        # @return [Boolean] true if optional
        def optional?
          !@required
        end

        # Check if attribute is enum type
        #
        # @return [Boolean] true if enum
        def enum?
          @type == :enum && !@values.nil?
        end

        # Validate value against schema
        #
        # @param value [Object] Value to validate
        # @return [Boolean] true if valid
        def valid_value?(value)
          return false if value.nil? && @required

          # Type-specific validation
          case @type
          when :enum
            @values.include?(value.to_s)
          when :integer
            value.is_a?(Integer) || value.to_s.match?(/^\d+$/)
          when :boolean
            [true, false, "true", "false", "1", "0"].include?(value)
          when :string
            true # Any value acceptable
          else
            true
          end
        end

        # Get property name for accessing in model
        #
        # Converts XML attribute name to Ruby property name.
        # Uses custom property mapping if specified in schema.
        #
        # @return [Symbol] Property name
        #
        # @example Property names
        #   val → :val
        #   lineRule → :line_rule
        #   w:val → :val
        #   id (with property: comment_id) → :comment_id
        def property_name
          # Use custom property name if specified
          return @property.to_sym if @property

          # Remove namespace prefix if present
          name_str = @tag.to_s.sub(/^w:/, "").sub(/^r:/, "")

          # Convert camelCase to snake_case
          name_str.gsub(/([A-Z])/, '_\1')
            .downcase
            .sub(/^_/, "")
            .to_sym
        end

        # Format value for XML output
        #
        # @param value [Object] Value to format
        # @return [String] Formatted value
        #
        # @example Format values
        #   format_value(true)   # => "1"
        #   format_value(false)  # => "0"
        #   format_value(42)     # => "42"
        def format_value(value)
          case @type
          when :boolean
            value ? "1" : "0"
          when :integer
            value.to_i.to_s
          when :enum
            validate_enum_value(value)
            value.to_s
          else
            value.to_s
          end
        end

        # Get XML attribute name with namespace
        #
        # @return [String] Full attribute name
        #
        # @example Attribute names
        #   attribute_name  # => "w:val" or "r:id"
        def attribute_name
          if @namespace && @prefix != "w"
            "#{@prefix}:#{@name}"
          else
            @tag
          end
        end

        private

        # Validate enum value
        #
        # @param value [Object] Value to validate
        # @raise [ArgumentError] if invalid enum value
        def validate_enum_value(value)
          return if @values.include?(value.to_s)

          raise ArgumentError,
                "Invalid value '#{value}' for attribute #{@name}. " \
                "Valid values: #{@values.join(', ')}"
        end
      end
    end
  end
end
