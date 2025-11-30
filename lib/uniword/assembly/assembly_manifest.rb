# frozen_string_literal: true

require 'yaml'

module Uniword
  module Assembly
    # Parses and validates assembly manifest YAML files.
    #
    # Responsibility: Parse assembly.yml configuration files.
    # Single Responsibility: Only handles manifest parsing and validation.
    #
    # The AssemblyManifest:
    # - Loads YAML assembly configuration
    # - Validates manifest structure
    # - Provides default values for optional settings
    # - Exposes configuration through a clean interface
    #
    # @example Basic manifest loading
    #   manifest = AssemblyManifest.new('assembly.yml')
    #   puts manifest.output_path
    #   puts manifest.template_name
    #
    # @example Accessing variables
    #   manifest = AssemblyManifest.new('assembly.yml')
    #   vars = manifest.variables
    #   puts vars['title']
    class AssemblyManifest
      # @return [String] Path to output file
      attr_reader :output_path

      # @return [String, nil] Template name
      attr_reader :template_name

      # @return [Hash] Template variables
      attr_reader :variables

      # @return [Array<Hash>] Section configurations
      attr_reader :sections

      # @return [Hash] Additional options
      attr_reader :options

      # Initialize manifest from YAML file.
      #
      # @param manifest_path [String] Path to assembly.yml file
      # @param override_variables [Hash] Variables to override manifest values
      #
      # @example Load manifest
      #   manifest = AssemblyManifest.new('assembly.yml')
      #
      # @example With variable overrides
      #   manifest = AssemblyManifest.new('assembly.yml',
      #     override_variables: { version: '2.0' }
      #   )
      def initialize(manifest_path, override_variables: {})
        @manifest_path = manifest_path
        @raw_data = load_yaml(manifest_path)

        validate_structure!

        parse_manifest
        apply_variable_overrides(override_variables)
      end

      # Check if manifest has a template.
      #
      # @return [Boolean] True if template is specified
      def template?
        !@template_name.nil?
      end

      # Get section configurations.
      #
      # @return [Array<Hash>] List of section definitions
      def section_list
        @sections.dup
      end

      # Get variable value by key.
      #
      # @param key [String, Symbol] Variable key
      # @return [Object, nil] Variable value
      def variable(key)
        @variables[key.to_s]
      end

      # Check if variable exists.
      #
      # @param key [String, Symbol] Variable key
      # @return [Boolean] True if variable is defined
      def variable?(key)
        @variables.key?(key.to_s)
      end

      private

      # Load YAML file.
      #
      # @param path [String] Path to YAML file
      # @return [Hash] Parsed YAML content
      def load_yaml(path)
        raise ArgumentError, "Manifest file not found: #{path}" unless File.exist?(path)

        YAML.load_file(path)
      rescue Psych::SyntaxError => e
        raise ArgumentError, "Invalid YAML in manifest: #{e.message}"
      end

      # Validate manifest structure.
      #
      # @raise [ArgumentError] If manifest structure is invalid
      def validate_structure!
        raise ArgumentError, 'Manifest must be a Hash' unless @raw_data.is_a?(Hash)

        unless @raw_data['document'].is_a?(Hash)
          raise ArgumentError, "Manifest must have 'document' key"
        end

        doc = @raw_data['document']

        raise ArgumentError, "Manifest must specify 'output' path" unless doc['output']

        return if doc['sections'].is_a?(Array)

        raise ArgumentError, "Manifest must have 'sections' array"
      end

      # Parse manifest data.
      def parse_manifest
        doc = @raw_data['document']

        @output_path = doc['output']
        @template_name = doc['template']
        @variables = parse_variables(doc['variables'])
        @sections = parse_sections(doc['sections'])
        @options = doc['options'] || {}
      end

      # Parse variables section.
      #
      # @param vars [Hash, nil] Variables from manifest
      # @return [Hash] Normalized variables
      def parse_variables(vars)
        return {} if vars.nil?

        raise ArgumentError, 'Variables must be a Hash' unless vars.is_a?(Hash)

        # Convert all keys to strings for consistency
        vars.transform_keys(&:to_s)
      end

      # Parse sections array.
      #
      # @param sections [Array] Sections from manifest
      # @return [Array<Hash>] Normalized section configurations
      def parse_sections(sections)
        sections.map.with_index do |section, index|
          unless section.is_a?(Hash)
            raise ArgumentError,
                  "Section at index #{index} must be a Hash"
          end

          unless section['component']
            raise ArgumentError,
                  "Section at index #{index} must have 'component' key"
          end

          {
            'component' => section['component'],
            'options' => section['options'] || {},
            'order' => section['order']
          }
        end
      end

      # Apply variable overrides.
      #
      # @param overrides [Hash] Variables to override
      def apply_variable_overrides(overrides)
        return if overrides.empty?

        overrides.each do |key, value|
          @variables[key.to_s] = value
        end
      end
    end
  end
end
