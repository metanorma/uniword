# frozen_string_literal: true

module Uniword
  module Ooxml
    module Schema
      # Represents the definition of ONE OOXML element type.
      #
      # Responsibility: Hold schema definition for a single element type.
      # Single Responsibility - represents one element's structure only.
      #
      # Loaded from external YAML schema configuration.
      #
      # @example Create from config
      #   definition = ElementDefinition.new({
      #     tag: 'w:p',
      #     description: 'Paragraph element',
      #     children: [...],
      #     attributes: [...]
      #   })
      class ElementDefinition
        attr_reader :tag, :description, :children, :attributes, :namespace

        # Initialize element definition from configuration
        #
        # @param definition [Hash] Element definition hash from YAML
        def initialize(definition)
          @tag = definition[:tag]
          @description = definition[:description]
          @namespace = definition[:namespace]
          @children = build_children(definition[:children] || [])
          @attributes = build_attributes(definition[:attributes] || [])
        end

        # Get namespace declarations for XML element
        #
        # @return [Hash] Namespace declarations
        #
        # @example Get namespaces
        #   declarations = element_def.namespace_declarations
        #   # => { 'xmlns:w' => 'http://...' }
        def namespace_declarations
          return {} unless @namespace

          prefix = tag.split(":").first
          { "xmlns:#{prefix}" => @namespace }
        end

        # Get child definition by element type
        #
        # @param element_type [Symbol, String] Child element type
        # @return [ChildDefinition, nil] Child definition if found
        #
        # @example Find child
        #   run_def = para_def.child(:run)
        def child(element_type)
          element_type = element_type.to_sym
          @children.find { |c| c.element_type == element_type }
        end

        # Get attribute definition by name
        #
        # @param attr_name [Symbol, String] Attribute name
        # @return [AttributeDefinition, nil] Attribute definition if found
        #
        # @example Find attribute
        #   val_attr = element_def.attribute(:val)
        def attribute(attr_name)
          attr_name = attr_name.to_sym
          @attributes.find { |a| a.name == attr_name }
        end

        # Check if element has children
        #
        # @return [Boolean] true if has child elements
        def has_children?
          !@children.empty?
        end

        # Check if element has attributes
        #
        # @return [Boolean] true if has attributes
        def has_attributes?
          !@attributes.empty?
        end

        # Get required children
        #
        # @return [Array<ChildDefinition>] Required child definitions
        def required_children
          @children.select(&:required?)
        end

        # Get optional children
        #
        # @return [Array<ChildDefinition>] Optional child definitions
        def optional_children
          @children.reject(&:required?)
        end

        # Get required attributes
        #
        # @return [Array<AttributeDefinition>] Required attribute definitions
        def required_attributes
          @attributes.select(&:required?)
        end

        # Get optional attributes
        #
        # @return [Array<AttributeDefinition>] Optional attribute definitions
        def optional_attributes
          @attributes.reject(&:required?)
        end

        # Get element tag without namespace prefix
        #
        # @return [String] Tag name without prefix
        #
        # @example Get local name
        #   element_def.local_name  # 'w:p' => 'p'
        def local_name
          @tag.split(":").last
        end

        # Get namespace prefix
        #
        # @return [String, nil] Namespace prefix
        #
        # @example Get prefix
        #   element_def.prefix  # 'w:p' => 'w'
        def prefix
          parts = @tag.split(":")
          parts.length > 1 ? parts.first : nil
        end

        private

        # Build child definitions from configuration
        #
        # @param children_config [Array<Hash>] Children configuration
        # @return [Array<ChildDefinition>] Child definitions
        def build_children(children_config)
          children_config.map { |child_def| ChildDefinition.new(child_def) }
        end

        # Build attribute definitions from configuration
        #
        # @param attributes_config [Array<Hash>] Attributes configuration
        # @return [Array<AttributeDefinition>] Attribute definitions
        def build_attributes(attributes_config)
          attributes_config.map { |attr_def| AttributeDefinition.new(attr_def) }
        end
      end
    end
  end
end
