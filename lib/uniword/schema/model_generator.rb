# frozen_string_literal: true

require 'fileutils'
require_relative 'schema_loader'

module Uniword
  module Schema
    # ModelGenerator generates lutaml-model classes from YAML schema definitions
    #
    # This generator creates complete, proper lutaml-model classes that follow
    # ALL architectural rules, especially Pattern 0 (attributes BEFORE xml blocks).
    #
    # @example Generate classes for WordProcessingML namespace
    #   generator = ModelGenerator.new('wordprocessingml')
    #   generator.generate_all
    class ModelGenerator
      attr_reader :schema_name, :namespace_info, :output_dir

      def initialize(schema_name, output_dir: nil)
        @schema_name = schema_name
        @loader = SchemaLoader.instance
        @namespace_info = @loader.namespace(schema_name)
        @output_dir = output_dir || File.join(__dir__, '../../generated', schema_name)
      end

      # Generate all classes for this schema
      #
      # @return [Hash] Map of element_name => generated_file_path
      def generate_all
        element_names = @loader.element_names(schema_name)

        # Ensure output directory exists
        FileUtils.mkdir_p(@output_dir)

        results = {}
        element_names.each do |element_name|
          file_path = generate_element_class(element_name)
          results[element_name] = file_path
        end

        results
      end

      # Generate a single element class
      #
      # @param element_name [String] Element XML tag name
      # @return [String] Path to generated file
      def generate_element_class(element_name)
        element_def = @loader.element_definition(schema_name, element_name)
        raise "Element '#{element_name}' not found in schema '#{schema_name}'" unless element_def

        # Ensure output directory exists
        FileUtils.mkdir_p(@output_dir)

        class_name = element_def['class_name']
        file_name = underscore(class_name)
        file_path = File.join(@output_dir, "#{file_name}.rb")

        code = generate_class_code(element_name, element_def)
        File.write(file_path, code)

        file_path
      end

      private

      # Generate complete class code
      #
      # @param element_name [String] XML element name
      # @param element_def [Hash] Element definition from schema
      # @return [String] Ruby class code
      def generate_class_code(element_name, element_def)
        class_name = element_def['class_name']
        description = element_def['description']
        attributes = element_def['attributes'] || []

        <<~RUBY
          # frozen_string_literal: true

          require 'lutaml/model'

          module Uniword
            module Generated
              module #{camelize(schema_name)}
                # #{description}
                #
                # Generated from OOXML schema: #{schema_name}.yml
                # Element: <#{@namespace_info['prefix']}:#{element_name}>
                class #{class_name} < Lutaml::Model::Serializable
          #{generate_attributes(attributes)}

          #{generate_xml_mapping(element_name, attributes)}
                end
              end
            end
          end
        RUBY
      end

      # Generate attribute declarations
      # CRITICAL: These MUST come BEFORE xml mapping (Pattern 0)
      #
      # @param attributes [Array<Hash>] Attribute definitions
      # @return [String] Attribute declaration code
      def generate_attributes(attributes)
        return '' if attributes.empty?

        lines = attributes.map do |attr|
          # Convert type to symbol for primitive types
          type_str = if %w[String
                           Integer].include?(attr['type'])
                       ":#{attr['type'].downcase}"
                     else
                       attr['type']
                     end
          attr_code = "          attribute :#{attr['name']}, #{type_str}"
          attr_code += ', collection: true' if attr['collection']
          attr_code += ', default: -> { [] }' if attr['collection']
          attr_code
        end

        lines.join("\n")
      end

      # Generate XML mapping block
      # CRITICAL: This comes AFTER attributes (Pattern 0)
      #
      # @param element_name [String] XML element name
      # @param attributes [Array<Hash>] Attribute definitions
      # @return [String] XML mapping code
      def generate_xml_mapping(element_name, attributes)
        lines = []
        lines << '          xml do'
        lines << "            element '#{element_name}'"
        lines << "            namespace '#{@namespace_info['uri']}', '#{@namespace_info['prefix']}'"
        lines << '            mixed_content' if has_nested_content?(attributes)
        lines << ''

        # Map each attribute
        attributes.each do |attr|
          if attr['xml_attribute']
            # Attribute value (e.g., <w:p w:val="value">)
            lines << "            map_attribute '#{attr['xml_name']}', to: :#{attr['name']}"
          else
            # Element value (e.g., <w:p><w:pPr>...</w:pPr></w:p>)
            map_line = "            map_element '#{attr['xml_name']}', to: :#{attr['name']}"
            map_line += ', render_nil: false' unless attr['required']
            lines << map_line
          end
        end

        lines << '          end'
        lines.join("\n")
      end

      # Check if element has nested content requiring mixed_content
      #
      # @param attributes [Array<Hash>] Attribute definitions
      # @return [Boolean] true if has nested elements
      def has_nested_content?(attributes)
        attributes.any? { |attr| attr['xml_name'] && !attr['xml_attribute'] }
      end

      # Convert CamelCase to snake_case
      #
      # @param str [String] CamelCase string
      # @return [String] snake_case string
      def underscore(str)
        str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
           .gsub(/([a-z\d])([A-Z])/, '\1_\2')
           .downcase
      end

      # Convert snake_case to CamelCase
      #
      # @param str [String] snake_case string
      # @return [String] CamelCase string
      def camelize(str)
        str.split('_').map(&:capitalize).join
      end
    end
  end
end
