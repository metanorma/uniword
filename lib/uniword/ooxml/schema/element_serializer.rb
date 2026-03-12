# frozen_string_literal: true

require 'nokogiri'

module Uniword
  module Ooxml
    module Schema
      # Schema-driven serializer for OOXML elements.
      #
      # Responsibility: Serialize ANY element to OOXML XML using schema definition.
      # Single Responsibility - element serialization only, schema-driven.
      #
      # Follows configuration over convention - serialization behavior
      # is defined by external YAML schema, not hardcoded logic.
      #
      # @example Serialize a paragraph
      #   serializer = ElementSerializer.new
      #   xml = serializer.serialize(paragraph)
      #
      # @example With custom schema
      #   schema = OoxmlSchema.load('custom_schema.yml')
      #   serializer = ElementSerializer.new(schema: schema)
      class ElementSerializer
        # Initialize element serializer
        #
        # @param schema [OoxmlSchema, nil] OOXML schema (loads default if nil)
        def initialize(schema: nil)
          @schema = schema || load_default_schema
        end

        # Serialize element to OOXML XML
        #
        # Uses schema definition to determine structure, attributes, children.
        #
        # @param element [Element] Element to serialize
        # @param options [Hash] Serialization options
        # @option options [Boolean] :pretty (false) Pretty print XML
        # @option options [Boolean] :standalone (true) Include XML declaration
        # @return [String] OOXML XML string
        # @raise [ArgumentError] if element has no schema definition
        #
        # @example Serialize paragraph
        #   xml = serializer.serialize(paragraph)
        #   # => "<w:p>...</w:p>"
        def serialize(element, options = {})
          validate_element(element)

          # Get schema definition
          schema_def = @schema.definition_for(element.class)

          # Build XML document
          doc = Nokogiri::XML::Document.new

          # Create root element with proper namespace
          root = serialize_element_to_node(doc, element, schema_def, options)
          doc.root = root

          # Format output
          xml_str = if options[:pretty]
                      doc.to_xml(indent: 2)
                    else
                      root.to_xml
                    end

          # Remove XML declaration unless standalone
          xml_str = xml_str.sub(/<\?xml[^?]*\?>\n?/, '') unless options.fetch(:standalone, false)

          # Add XML declaration if standalone
          xml_str = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n#{xml_str}" if options.fetch(
            :standalone, false
          )

          xml_str.strip
        end

        private

        # Load default OOXML schema
        #
        # @return [OoxmlSchema] Default schema
        def load_default_schema
          schema_path = File.expand_path('../../../../config/ooxml/schema_main.yml', __dir__)
          OoxmlSchema.load(schema_path)
        end

        # Serialize element to Nokogiri node
        #
        # @param doc [Nokogiri::XML::Document] XML document
        # @param element [Element] Element to serialize
        # @param schema_def [ElementDefinition] Schema definition
        # @param options [Hash] Serialization options
        # @return [Nokogiri::XML::Node] Created node
        def serialize_element_to_node(doc, element, schema_def, options)
          # Create element node with namespace
          prefix = schema_def.prefix
          local_name = schema_def.local_name
          namespace_uri = @schema.namespace[:uri]

          node = Nokogiri::XML::Node.new(local_name, doc)
          node.namespace = node.add_namespace_definition(prefix, namespace_uri)

          # Serialize attributes according to schema
          serialize_attributes_to_node(node, element, schema_def)

          # Serialize children according to schema
          serialize_children_to_node(doc, node, element, schema_def, options)

          node
        end

        # Serialize element attributes to node
        #
        # @param node [Nokogiri::XML::Node] Node to add attributes to
        # @param element [Element] Element with attributes
        # @param schema_def [ElementDefinition] Schema definition
        def serialize_attributes_to_node(node, element, schema_def)
          schema_def.attributes.each do |attr_def|
            # Get attribute value from element
            value = get_attribute_value(element, attr_def)

            # Skip if nil (whether required or not - allows auto-generation in models)
            next if value.nil?

            # Validate value
            unless attr_def.valid_value?(value)
              raise ArgumentError,
                    "Invalid value for attribute #{attr_def.name}: #{value.inspect}"
            end

            # Format and set attribute
            formatted_value = attr_def.format_value(value)
            node[attr_def.attribute_name] = formatted_value
          end
        end

        # Serialize element children to node
        #
        # @param doc [Nokogiri::XML::Document] XML document
        # @param node [Nokogiri::XML::Node] Parent node
        # @param element [Element] Element with children
        # @param schema_def [ElementDefinition] Schema definition
        # @param options [Hash] Serialization options
        def serialize_children_to_node(doc, node, element, schema_def, options)
          schema_def.children.each do |child_def|
            # Get child element(s) from parent
            children = get_child_elements(element, child_def)

            # Skip if no children and optional
            next if children.nil? && child_def.optional?
            next if children.respond_to?(:empty?) && children.empty? && child_def.optional?

            # Serialize child elements
            if child_def.multiple?
              # Serialize each child in collection
              Array(children).each do |child|
                child_node = serialize_child_to_node(doc, child, child_def, options)
                node.add_child(child_node) if child_node
              end
            elsif children
              # Serialize single child
              child_node = serialize_child_to_node(doc, children, child_def, options)
              node.add_child(child_node) if child_node
            end
          end
        end

        # Serialize a single child element to node
        #
        # @param doc [Nokogiri::XML::Document] XML document
        # @param child [Element, Object] Child element or value
        # @param child_def [ChildDefinition] Child schema definition
        # @param options [Hash] Serialization options
        # @return [Nokogiri::XML::Node, nil] Created node
        def serialize_child_to_node(doc, child, child_def, options)
          # Get namespace prefix from tag (e.g., 'w:p' -> 'w')
          tag_parts = child_def.tag.split(':')
          prefix = tag_parts.length > 1 ? tag_parts.first : 'w'
          local_name = tag_parts.last
          namespace_uri = @schema.namespace[:uri]

          if child_def.presence_only?
            # Presence-only element (e.g., <w:b/> for bold)
            node = Nokogiri::XML::Node.new(local_name, doc)
            node.namespace = node.add_namespace_definition(prefix, namespace_uri)
            node
          elsif child.is_a?(String)
            # Simple string value (e.g., text content)
            node = Nokogiri::XML::Node.new(local_name, doc)
            node.namespace = node.add_namespace_definition(prefix, namespace_uri)
            node.content = child
            node
          elsif child.respond_to?(:is_a?) && child.is_a?(Element)
            # Check if this is a TextElement that needs special handling
            if child.instance_of?(::Uniword::TextElement) && child.respond_to?(:content)
              # TextElement: serialize as element with text content
              node = Nokogiri::XML::Node.new(local_name, doc)
              node.namespace = node.add_namespace_definition(prefix, namespace_uri)
              node.content = child.content.to_s if child.content
              node
            else
              # Recursively serialize element child
              child_schema_def = @schema.definition_for(child.class)
              serialize_element_to_node(doc, child, child_schema_def, options)
            end
          elsif child.is_a?(Lutaml::Model::Serializable)
            # Child is a Lutaml::Model object (like properties) - serialize it recursively
            # Try to find schema definition
            if @schema.has_element?(child.class)
              child_schema_def = @schema.definition_for(child.class)
              serialize_element_to_node(doc, child, child_schema_def, options)
            else
              # For properties without schema, create empty element
              # (will be filled with children if schema definition exists for element type)
              node = Nokogiri::XML::Node.new(local_name, doc)
              node.namespace = node.add_namespace_definition(prefix, namespace_uri)

              if child_def.has_attributes?
                child_def.attributes.each do |attr_config|
                  attr_def = AttributeDefinition.new(attr_config)
                  value = get_attribute_value(child, attr_def)
                  node[attr_def.attribute_name] = attr_def.format_value(value) if value
                end
              end
              node
            end
          elsif child_def.has_attributes?
            # Element with attributes but no child elements
            node = Nokogiri::XML::Node.new(local_name, doc)
            node.namespace = node.add_namespace_definition(prefix, namespace_uri)

            child_def.attributes.each do |attr_config|
              attr_def = AttributeDefinition.new(attr_config)
              value = get_attribute_value(child, attr_def)
              node[attr_def.attribute_name] = attr_def.format_value(value) if value
            end
            node
          elsif child.is_a?(String)
            # Simple string value
            node = Nokogiri::XML::Node.new(local_name, doc)
            node.namespace = node.add_namespace_definition(prefix, namespace_uri)
            node.content = child
            node
          elsif child.respond_to?(:content)
            # TextElement or similar - get the content
            node = Nokogiri::XML::Node.new(local_name, doc)
            node.namespace = node.add_namespace_definition(prefix, namespace_uri)
            node.content = child.content.to_s if child.content
            node
          elsif child
            # Other value element - convert to string
            node = Nokogiri::XML::Node.new(local_name, doc)
            node.namespace = node.add_namespace_definition(prefix, namespace_uri)
            node.content = child.to_s
            node
          end
        end

        # Get attribute value from element
        #
        # @param element [Element] Element object
        # @param attr_def [AttributeDefinition] Attribute definition
        # @return [Object, nil] Attribute value
        def get_attribute_value(element, attr_def)
          property_name = attr_def.property_name

          # Try to get value using property name
          if element.respond_to?(property_name)
            element.send(property_name)
          elsif element.respond_to?(:attributes) && element.attributes.is_a?(Hash) && element.attributes.key?(property_name)
            element.attributes[property_name]
          end
        end

        # Get child elements from parent element
        #
        # @param element [Element] Parent element
        # @param child_def [ChildDefinition] Child definition
        # @return [Element, Array<Element>, nil] Child element(s)
        def get_child_elements(element, child_def)
          property_name = child_def.property_name

          # Try to get children using property name
          if element.respond_to?(property_name)
            element.send(property_name)
          elsif element.respond_to?(:attributes) && element.attributes.key?(property_name)
            element.attributes[property_name]
          end
        end

        # Validate element
        #
        # @param element [Object] Object to validate
        # @raise [ArgumentError] if not a valid element
        def validate_element(element)
          return if element.respond_to?(:is_a?) && element.is_a?(Element)

          raise ArgumentError,
                "Element must be a Uniword::Element, got #{element.class}"
        end
      end
    end
  end
end
