# frozen_string_literal: true

module Uniword
  module Validation
    # Represents the result of validating a single layer of document structure.
    #
    # Responsibility: Store validation outcome for one layer (file, ZIP, XML, etc.)
    # Single Responsibility: Only represents layer validation results.
    #
    # A layer validation result includes:
    # - Layer name
    # - Collection of errors (critical and non-critical)
    # - Collection of warnings
    # - Collection of info messages
    #
    # @example Create a result
    #   result = LayerValidationResult.new('File Structure')
    #   result.add_error('File does not exist', critical: true)
    #   result.valid? # => false
    class LayerValidationResult
      # @return [String] Name of the validation layer
      attr_reader :layer_name

      # @return [Array<Hash>] Collection of errors
      attr_reader :errors

      # @return [Array<Hash>] Collection of warnings
      attr_reader :warnings

      # @return [Array<Hash>] Collection of info messages
      attr_reader :infos

      # Initialize a new LayerValidationResult.
      #
      # @param layer_name [String] Name of the validation layer
      #
      # @example Create a result
      #   result = LayerValidationResult.new('ZIP Integrity')
      def initialize(layer_name)
        @layer_name = layer_name
        @errors = []
        @warnings = []
        @infos = []
      end

      # Add an error to this layer's results.
      #
      # @param message [String] Error message
      # @param critical [Boolean] Whether this is a critical error
      # @return [LayerValidationResult] Self for method chaining
      #
      # @example Add a critical error
      #   result.add_error('File is corrupted', critical: true)
      def add_error(message, critical: false)
        @errors << { message: message, critical: critical }
        self
      end

      # Add a warning to this layer's results.
      #
      # @param message [String] Warning message
      # @return [LayerValidationResult] Self for method chaining
      #
      # @example Add a warning
      #   result.add_warning('File is very large')
      def add_warning(message)
        @warnings << { message: message }
        self
      end

      # Add an info message to this layer's results.
      #
      # @param message [String] Info message
      # @return [LayerValidationResult] Self for method chaining
      #
      # @example Add info
      #   result.add_info('Optional part missing')
      def add_info(message)
        @infos << { message: message }
        self
      end

      # Check if this layer validation passed.
      #
      # @return [Boolean] true if no errors
      #
      # @example
      #   result.valid? # => false
      def valid?
        @errors.empty?
      end

      # Check if this layer has critical failures.
      #
      # @return [Boolean] true if any critical errors
      #
      # @example
      #   result.critical_failures? # => true
      def critical_failures?
        @errors.any? { |error| error[:critical] }
      end

      # Get count of errors.
      #
      # @return [Integer] Error count
      def error_count
        @errors.count
      end

      # Get count of warnings.
      #
      # @return [Integer] Warning count
      def warning_count
        @warnings.count
      end

      # Get count of info messages.
      #
      # @return [Integer] Info count
      def info_count
        @infos.count
      end

      # Convert to hash representation.
      #
      # @return [Hash] Hash representation
      #
      # @example
      #   result.to_h
      #   # => { layer: 'File Structure', valid: false, errors: [...] }
      def to_h
        {
          layer: @layer_name,
          valid: valid?,
          critical_failures: critical_failures?,
          errors: @errors,
          warnings: @warnings,
          infos: @infos
        }
      end

      # Convert to string for display.
      #
      # @return [String] String representation
      def to_s
        status = valid? ? 'PASS' : 'FAIL'
        details = []
        details << "#{error_count} error(s)" if error_count > 0
        details << "#{warning_count} warning(s)" if warning_count > 0
        details << "#{info_count} info(s)" if info_count > 0

        detail_str = details.empty? ? '' : " (#{details.join(', ')})"
        "[#{status}] #{@layer_name}#{detail_str}"
      end
    end
  end
end