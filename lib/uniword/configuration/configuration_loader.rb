# frozen_string_literal: true

require 'yaml'
require_relative '../errors'

module Uniword
  module Configuration
    # Loads and manages external configuration files.
    #
    # Responsibility: Load configuration from external YAML files.
    # Single Responsibility - only handles configuration loading.
    #
    # Follows "Configuration over Convention" principle - all configurable
    # behavior is defined in external YAML files, not hardcoded in classes.
    #
    # @example Load transformation rules
    #   config = ConfigurationLoader.load('transformation_rules')
    #   property_mappings = config['property_mappings']
    #
    # @example Load with custom path
    #   config = ConfigurationLoader.load_file('/custom/path/rules.yml')
    class ConfigurationLoader
      # Default configuration directory
      CONFIG_DIR = File.expand_path('../../../config', __dir__)

      class << self
        # Load configuration from a named file in the config directory
        #
        # @param name [String] Configuration file name (without .yml)
        # @return [Hash] Loaded configuration
        # @raise [ConfigurationError] if file not found or invalid
        #
        # @example Load transformation rules
        #   config = ConfigurationLoader.load('transformation_rules')
        def load(name)
          file_path = File.join(CONFIG_DIR, "#{name}.yml")
          load_file(file_path)
        end

        # Load configuration from a specific file path
        #
        # @param path [String] Full path to configuration file
        # @return [Hash] Loaded configuration
        # @raise [ConfigurationError] if file not found or invalid
        #
        # @example Load from custom path
        #   config = ConfigurationLoader.load_file('/custom/rules.yml')
        def load_file(path)
          validate_file_exists(path)

          content = File.read(path)
          parsed = YAML.safe_load(content, permitted_classes: [Symbol])

          validate_configuration(parsed, path)

          # Convert string keys to symbols for easier access
          deep_symbolize_keys(parsed)
        rescue Psych::SyntaxError => e
          raise ConfigurationError,
                "Invalid YAML in #{path}: #{e.message}"
        rescue StandardError => e
          raise ConfigurationError,
                "Failed to load configuration from #{path}: #{e.message}"
        end

        # Get a configuration value with dot notation
        #
        # @param config [Hash] Configuration hash
        # @param key_path [String] Dot-separated key path (e.g., 'format_defaults.docx.default_font')
        # @param default [Object] Default value if key not found
        # @return [Object] Configuration value or default
        #
        # @example Get nested value
        #   font = ConfigurationLoader.get(config, 'format_defaults.docx.default_font')
        def get(config, key_path, default = nil)
          keys = key_path.split('.')
          value = keys.reduce(config) do |hash, key|
            return default unless hash.is_a?(Hash)
            hash[key.to_sym] || hash[key.to_s]
          end
          value || default
        end

        # Merge two configuration hashes
        #
        # @param base [Hash] Base configuration
        # @param override [Hash] Override configuration
        # @return [Hash] Merged configuration
        #
        # @example Merge configurations
        #   merged = ConfigurationLoader.merge(default_config, user_config)
        def merge(base, override)
          deep_merge(base.dup, override)
        end

        private

        # Validate file exists
        #
        # @param path [String] File path
        # @raise [ConfigurationError] if file doesn't exist
        def validate_file_exists(path)
          return if File.exist?(path)

          raise ConfigurationError,
                "Configuration file not found: #{path}"
        end

        # Validate configuration structure
        #
        # @param config [Object] Parsed configuration
        # @param path [String] File path for error messages
        # @raise [ConfigurationError] if configuration is invalid
        def validate_configuration(config, path)
          unless config.is_a?(Hash)
            raise ConfigurationError,
                  "Configuration must be a Hash, got #{config.class} in #{path}"
          end

          if config.empty?
            raise ConfigurationError,
                  "Configuration cannot be empty in #{path}"
          end
        end

        # Convert all string keys to symbols recursively
        #
        # @param obj [Object] Object to convert
        # @return [Object] Object with symbolized keys
        def deep_symbolize_keys(obj)
          case obj
          when Hash
            obj.each_with_object({}) do |(key, value), result|
              result[key.to_sym] = deep_symbolize_keys(value)
            end
          when Array
            obj.map { |item| deep_symbolize_keys(item) }
          else
            obj
          end
        end

        # Deep merge two hashes
        #
        # @param base [Hash] Base hash
        # @param override [Hash] Override hash
        # @return [Hash] Merged hash
        def deep_merge(base, override)
          override.each do |key, value|
            base[key] = if base[key].is_a?(Hash) && value.is_a?(Hash)
                         deep_merge(base[key], value)
                       else
                         value
                       end
          end
          base
        end
      end
    end

    # Error raised when configuration loading fails
    class ConfigurationError < Error
      def initialize(message)
        super("Configuration error: #{message}")
      end
    end
  end
end