# frozen_string_literal: true

module Uniword
  module Ooxml
    module Schema
      # Represents the definition of a child element relationship.
      #
      # Responsibility: Define how ONE child element relates to its parent.
      # Single Responsibility - child relationship definition only.
      #
      # Loaded from external YAML schema configuration.
      #
      # @example Create from config
      #   child_def = ChildDefinition.new({
      #     element: :run,
      #     tag: 'w:r',
      #     multiple: true,
      #     optional: true
      #   })
      class ChildDefinition
        attr_reader :element_type, :tag, :optional, :multiple, :required

        # Initialize child definition from configuration
        #
        # @param definition [Hash] Child definition hash from YAML
        def initialize(definition)
          @element_type = definition[:element]&.to_sym
          @tag = definition[:tag]
          @optional = definition.fetch(:optional, true)
          @multiple = definition.fetch(:multiple, false)
          @required = definition.fetch(:required, false)
          @presence_only = definition.fetch(:presence_only, false)
          @attributes = definition[:attributes] || []
        end

        # Check if child is optional
        #
        # @return [Boolean] true if optional
        def optional?
          @optional
        end

        # Check if multiple children allowed
        #
        # @return [Boolean] true if multiple
        def multiple?
          @multiple
        end

        # Check if child is required
        #
        # @return [Boolean] true if required
        def required?
          @required
        end

        # Check if element is presence-only (no value)
        #
        # Some OOXML elements like <w:b/> have no value,
        # their presence alone indicates the property is true.
        #
        # @return [Boolean] true if presence-only
        #
        # @example Presence-only elements
        #   <w:b/>  # Bold = true by presence
        #   <w:i/>  # Italic = true by presence
        def presence_only?
          @presence_only
        end

        # Check if child has attributes
        #
        # @return [Boolean] true if has attributes
        def has_attributes?
          !@attributes.empty?
        end

        # Get attributes for this child
        #
        # @return [Array<Hash>] Attribute definitions
        attr_reader :attributes

        # Get property name for accessing child in model
        #
        # Converts element_type to Ruby property name.
        #
        # @return [Symbol] Property name
        #
        # @example Property names
        #   run → :runs (if multiple)
        #   paragraph_properties → :properties
        def property_name
          name = @element_type.to_s

          # Handle special cases
          name = case name
                 when "paragraph_properties"
                   "properties"
                 when "run_properties"
                   "properties"
                 when "table_properties"
                   "properties"
                 when "table_cell_properties"
                   "properties"
                 when "table_row_properties"
                   "properties"
                 when "text"
                   "text_element"
                 when "table_row"
                   "row"
                 when "table_cell"
                   "cell"
                 else
                   name
                 end

          # Pluralize if multiple
          name = "#{name}s" if @multiple && !name.end_with?("s")

          name.to_sym
        end
      end
    end
  end
end
