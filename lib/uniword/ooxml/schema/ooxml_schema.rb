# frozen_string_literal: true


module Uniword
  module Ooxml
    module Schema
      # OOXML Schema loaded from external YAML configuration.
      #
      # Responsibility: Load and provide access to OOXML element definitions.
      # Single Responsibility - schema management only.
      #
      # Follows "Configuration over Convention" - schema is defined in
      # external YAML files following ISO/IEC 29500 specification.
      #
      # @example Load schema
      #   schema = OoxmlSchema.load('config/ooxml/schema_main.yml')
      #   definition = schema.definition_for(Paragraph)
      #
      # @example Get element definition
      #   para_def = schema.element('paragraph')
      #   puts para_def.tag  # => 'w:p'
      class OoxmlSchema
        attr_reader :version, :namespace, :elements

        # Load schema from YAML file or multi-file loader
        #
        # @param schema_file [String, nil] Path to schema YAML file or nil for default
        # @return [OoxmlSchema] Loaded schema
        # @raise [ConfigurationError] if schema file invalid
        #
        # @example Load main schema (legacy single file)
        #   schema = OoxmlSchema.load('config/ooxml/schema_main.yml')
        #
        # @example Load multi-file schema (default)
        #   schema = OoxmlSchema.load
        def self.load(schema_file = nil)
          schema_file ||= default_loader_path

          # Check if this is a loader configuration or direct schema file
          if loader_config?(schema_file)
            load_from_loader(schema_file)
          else
            # Legacy single-file loading
            config = Configuration::ConfigurationLoader.load_file(schema_file)
            new(config)
          end
        end

        # Load schema from multi-file loader configuration
        #
        # @param loader_file [String] Path to schema loader YAML
        # @return [OoxmlSchema] Loaded schema
        def self.load_from_loader(loader_file)
          loader_config = Configuration::ConfigurationLoader.load_file(loader_file)
          combined_schema = aggregate_schema_files(loader_config, loader_file)
          new(combined_schema)
        end

        # Initialize schema from configuration hash
        #
        # @param config [Hash] Parsed YAML configuration
        def initialize(config)
          validate_schema_config(config)

          @version = config.dig(:schema, :version)
          @namespace = config.dig(:schema, :namespace)
          @elements = build_element_definitions(config[:elements] || {})
        end

        # Get element definition by element class or name
        #
        # @param element_class_or_name [Class, Symbol, String] Element class or name
        # @return [ElementDefinition] Element definition
        # @raise [ArgumentError] if element not found in schema
        #
        # @example Get by class
        #   definition = schema.definition_for(Paragraph)
        #
        # @example Get by name
        #   definition = schema.definition_for(:paragraph)
        def definition_for(element_class_or_name)
          name = normalize_name(element_class_or_name)
          @elements[name] || raise_element_not_found(name)
        end

        # Get element definition by name (alias for definition_for)
        #
        # @param name [Symbol] Element name
        # @return [ElementDefinition] Element definition
        def element(name)
          @elements[name.to_sym]
        end

        # Check if schema has definition for element
        #
        # @param element_class_or_name [Class, Symbol] Element class or name
        # @return [Boolean] true if defined
        def has_element?(element_class_or_name)
          name = normalize_name(element_class_or_name)
          @elements.key?(name)
        end

        # Get all element names
        #
        # @return [Array<Symbol>] Array of element names
        def element_names
          @elements.keys
        end

        # Get count of defined elements
        #
        # @return [Integer] Number of elements in schema
        def element_count
          @elements.count
        end

        private

        # Build element definitions from configuration
        #
        # @param elements_config [Hash] Elements configuration hash
        # @return [Hash<Symbol, ElementDefinition>] Element definitions
        def build_element_definitions(elements_config)
          elements_config.transform_values do |definition|
            ElementDefinition.new(definition)
          end
        end

        # Normalize element class or name to symbol
        #
        # @param element_class_or_name [Class, Symbol, String] Element identifier
        # @return [Symbol] Normalized element name
        def normalize_name(element_class_or_name)
          case element_class_or_name
          when Class
            # Convert Uniword::Paragraph → :paragraph
            element_class_or_name.name.split('::').last.downcase.to_sym
          when Symbol
            element_class_or_name
          when String
            element_class_or_name.to_sym
          else
            raise ArgumentError,
                  "Expected Class, Symbol, or String, got #{element_class_or_name.class}"
          end
        end

        # Validate schema configuration structure
        #
        # @param config [Hash] Schema configuration
        # @raise [ConfigurationError] if invalid
        def validate_schema_config(config)
          unless config.is_a?(Hash)
            raise Configuration::ConfigurationError,
                  'Schema configuration must be a Hash'
          end

          unless config[:schema]
            raise Configuration::ConfigurationError,
                  "Schema configuration must have 'schema' section"
          end

          return if config[:elements]

          raise Configuration::ConfigurationError,
                "Schema configuration must have 'elements' section"
        end

        # Raise error for element not found
        #
        # @param name [Symbol] Element name
        # @raise [ArgumentError]
        def raise_element_not_found(name)
          raise ArgumentError,
                "No schema definition for element: #{name}. " \
                "Available elements: #{element_names.join(', ')}"
        end

        # Check if file is a loader configuration
        #
        # @param file_path [String] Path to file
        # @return [Boolean] true if loader config
        def self.loader_config?(file_path)
          file_path.end_with?('schema_loader.yml')
        end

        # Aggregate multiple schema files into single schema
        #
        # @param loader_config [Hash] Loader configuration
        # @param loader_file [String] Path to loader file
        # @return [Hash] Combined schema configuration
        def self.aggregate_schema_files(loader_config, loader_file)
          base_path = File.dirname(loader_file)
          all_elements = {}

          # Load each schema file and merge elements
          loader_config[:schema_files].each do |schema_file|
            file_path = File.join(base_path, schema_file)

            next unless File.exist?(file_path)

            file_config = Configuration::ConfigurationLoader.load_file(file_path)

            # Merge elements from this file
            all_elements.merge!(file_config[:elements]) if file_config[:elements]
          end

          # Build combined schema configuration
          {
            schema: {
              version: loader_config[:version],
              namespace: loader_config[:namespaces]&.dig(:w)
            },
            elements: all_elements
          }
        end

        # Get default loader path
        #
        # @return [String] Path to default schema loader
        def self.default_loader_path
          File.expand_path('../../../../config/ooxml/schema_loader.yml', __dir__)
        end
      end
    end
  end
end
