# frozen_string_literal: true

module Uniword
  module Quality
    # Base class for document quality rules.
    #
    # Responsibility: Define the interface for quality checking rules.
    # Each rule checks one specific aspect of document quality.
    #
    # Follows Single Responsibility Principle - one rule checks one quality aspect.
    # Follows Open/Closed Principle - new rules can be added without modifying this class.
    #
    # @example Create a custom quality rule
    #   class CustomRule < QualityRule
    #     def initialize(config = {})
    #       super(config)
    #       @threshold = config[:threshold] || 100
    #     end
    #
    #     def check(document)
    #       violations = []
    #       # Perform checks and add violations
    #       violations
    #     end
    #   end
    class QualityRule
      attr_reader :config, :enabled

      # Initialize quality rule
      #
      # @param config [Hash] Rule configuration
      # @option config [Boolean] :enabled Whether rule is enabled
      def initialize(config = {})
        @config = config || {}
        @enabled = @config.fetch(:enabled, true)
      end

      # Check if rule is enabled
      #
      # @return [Boolean] true if rule should be executed
      def enabled?
        @enabled
      end

      # Check document for quality violations
      #
      # @param document [Document] The document to check
      # @return [Array<QualityViolation>] List of violations found
      def check(document)
        raise NotImplementedError, "#{self.class} must implement #check"
      end

      # Get rule name (used for identification)
      #
      # @return [String] Rule name
      def name
        self.class.name.split('::').last
          .gsub(/Rule$/, '')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .downcase
      end

      protected

      # Create a violation
      #
      # @param severity [Symbol] Violation severity (:error, :warning, :info)
      # @param message [String] Violation message
      # @param location [String] Location in document
      # @param element [Element] Element causing violation (optional)
      # @return [QualityViolation] The violation object
      def create_violation(severity:, message:, location:, element: nil)
        QualityViolation.new(
          rule: name,
          severity: severity,
          message: message,
          location: location,
          element: element
        )
      end
    end

    # Represents a quality violation found in a document
    class QualityViolation
      attr_reader :rule, :severity, :message, :location, :element

      # Initialize violation
      #
      # @param rule [String] Rule that found the violation
      # @param severity [Symbol] Violation severity (:error, :warning, :info)
      # @param message [String] Human-readable violation message
      # @param location [String] Location in document
      # @param element [Element] Element causing violation (optional)
      def initialize(rule:, severity:, message:, location:, element: nil)
        @rule = rule
        @severity = severity
        @message = message
        @location = location
        @element = element

        validate_severity!
      end

      # Check if violation is an error
      #
      # @return [Boolean] true if severity is :error
      def error?
        severity == :error
      end

      # Check if violation is a warning
      #
      # @return [Boolean] true if severity is :warning
      def warning?
        severity == :warning
      end

      # Check if violation is info
      #
      # @return [Boolean] true if severity is :info
      def info?
        severity == :info
      end

      # Convert violation to hash
      #
      # @return [Hash] Violation as hash
      def to_h
        {
          rule: rule,
          severity: severity,
          message: message,
          location: location
        }
      end

      private

      # Validate severity value
      #
      # @raise [ArgumentError] if severity is invalid
      def validate_severity!
        valid_severities = %i[error warning info]
        return if valid_severities.include?(severity)

        raise ArgumentError,
              "Invalid severity: #{severity}. " \
              "Must be one of: #{valid_severities.join(', ')}"
      end
    end
  end
end