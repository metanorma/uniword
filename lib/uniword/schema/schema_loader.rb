# frozen_string_literal: true

require 'yaml'
require 'singleton'

module Uniword
  module Schema
    # SchemaLoader loads and caches OOXML schema definitions from YAML files
    #
    # This class follows the Singleton pattern to ensure schemas are loaded once
    # and reused throughout the application lifecycle.
    #
    # @example Load a schema
    #   loader = SchemaLoader.instance
    #   wordprocessingml = loader.load_schema('wordprocessingml')
    #   element_def = loader.element_definition('wordprocessingml', 'p')
    class SchemaLoader
      include Singleton

      def initialize
        @schemas = {}
        @schema_path = File.join(__dir__, '../../../config/ooxml/schemas')
      end

      # Load a schema by name
      #
      # @param schema_name [String] Name of the schema file (without .yml extension)
      # @return [Hash] Parsed schema definition
      # @raise [SchemaNotFoundError] if schema file doesn't exist
      def load_schema(schema_name)
        return @schemas[schema_name] if @schemas.key?(schema_name)

        schema_file = File.join(@schema_path, "#{schema_name}.yml")
        unless File.exist?(schema_file)
          raise SchemaNotFoundError,
                "Schema file not found: #{schema_file}"
        end

        @schemas[schema_name] = YAML.load_file(schema_file)
      end

      # Get element definition from a schema
      #
      # @param schema_name [String] Schema name
      # @param element_name [String] Element XML tag name
      # @return [Hash, nil] Element definition or nil if not found
      def element_definition(schema_name, element_name)
        schema = load_schema(schema_name)
        schema.dig('elements', element_name)
      end

      # Get namespace information for a schema
      #
      # @param schema_name [String] Schema name
      # @return [Hash] Namespace definition with :uri, :prefix, :description
      def namespace(schema_name)
        schema = load_schema(schema_name)
        schema['namespace']
      end

      # Get all element names in a schema
      #
      # @param schema_name [String] Schema name
      # @return [Array<String>] Element names
      def element_names(schema_name)
        schema = load_schema(schema_name)
        schema['elements']&.keys || []
      end

      # Clear cached schemas (useful for testing)
      #
      # @return [void]
      def clear_cache!
        @schemas.clear
      end

      # Get all available schemas
      #
      # @return [Array<String>] Schema names
      def available_schemas
        Dir.glob(File.join(@schema_path, '*.yml')).map do |file|
          File.basename(file, '.yml')
        end
      end
    end

    # Raised when a schema file cannot be found
    class SchemaNotFoundError < StandardError; end
  end
end
