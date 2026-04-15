# frozen_string_literal: true

# LayerValidationResult autoloaded via lib/uniword/validation.rb

module Uniword
  module Validation
    # Base class for all layer validators.
    #
    # Responsibility: Define the interface for layer validation.
    # Single Responsibility: Only provides validation interface.
    #
    # Each layer validator validates one specific aspect of document structure:
    # - File structure (existence, permissions, etc.)
    # - ZIP integrity (valid archive, no corruption)
    # - OOXML parts (required files present)
    # - XML schema (well-formed XML)
    # - Relationships (valid references)
    # - Content types (consistent type declarations)
    # - Document semantics (valid structure)
    #
    # @example Implement a validator
    #   class MyValidator < LayerValidator
    #     def layer_name
    #       'My Layer'
    #     end
    #
    #     def validate(path)
    #       result = LayerValidationResult.new(layer_name)
    #       # Perform validation
    #       result.add_error('Something wrong') unless valid?
    #       result
    #     end
    #   end
    class LayerValidator
      # @return [Hash] Configuration for this validator
      attr_reader :config

      # Initialize a layer validator.
      #
      # @param config [Hash] Configuration hash
      #
      # @example Create a validator
      #   validator = MyValidator.new(config)
      def initialize(config = {})
        @config = config || {}
      end

      # Get the name of this validation layer.
      #
      # @return [String] Layer name
      # @raise [NotImplementedError] Must be implemented by subclass
      #
      # @example
      #   validator.layer_name # => 'File Structure'
      def layer_name
        raise NotImplementedError,
              "#{self.class} must implement #layer_name"
      end

      # Validate the document at this layer.
      #
      # @param path [String] Path to the document file
      # @return [LayerValidationResult] Validation result
      # @raise [NotImplementedError] Must be implemented by subclass
      #
      # @example
      #   result = validator.validate('/path/to/document.docx')
      def validate(path)
        raise NotImplementedError,
              "#{self.class} must implement #validate"
      end

      # Check if this validator is enabled.
      #
      # @return [Boolean] true if enabled
      #
      # @example
      #   validator.enabled? # => true
      def enabled?
        layer_config = @config[config_key]
        return true if layer_config.nil?

        layer_config[:enabled] != false
      end

      private

      # Get the configuration key for this layer.
      #
      # Converts class name to snake_case config key.
      # Example: FileStructureValidator -> :file_structure
      #
      # @return [Symbol] Configuration key
      def config_key
        name = self.class.name.split("::").last
        name = name.gsub(/Validator$/, "")
        name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
            .gsub(/([a-z\d])([A-Z])/, '\1_\2')
            .downcase
            .to_sym
      end
    end
  end
end
