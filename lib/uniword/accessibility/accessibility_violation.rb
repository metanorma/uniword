# frozen_string_literal: true

module Uniword
  module Accessibility
    # Accessibility Violation - individual accessibility issue
    #
    # Responsibility: Represent a single accessibility violation
    # Single Responsibility: Data structure for violations only
    #
    # @example Creating a violation
    #   violation = AccessibilityViolation.new(
    #     rule_id: :image_alt_text,
    #     wcag_criterion: "1.1.1 Non-text Content",
    #     level: "A",
    #     message: "Image 1 missing alternative text",
    #     element: image,
    #     severity: :error,
    #     suggestion: "Add descriptive alt text"
    #   )
    class AccessibilityViolation
      attr_reader :rule_id, :wcag_criterion, :level, :message,
                  :element, :severity, :suggestion

      # Initialize a new accessibility violation
      #
      # @param attributes [Hash] Violation attributes
      # @option attributes [Symbol] :rule_id Rule identifier
      # @option attributes [String] :wcag_criterion WCAG criterion number
      # @option attributes [String] :level WCAG level (A, AA, AAA)
      # @option attributes [String] :message Violation message
      # @option attributes [Object] :element Element with violation
      # @option attributes [Symbol] :severity Severity level
      # @option attributes [String] :suggestion Fix suggestion
      def initialize(attributes)
        @rule_id = attributes[:rule_id]
        @wcag_criterion = attributes[:wcag_criterion]
        @level = attributes[:level]
        @message = attributes[:message]
        @element = attributes[:element]
        @severity = attributes[:severity]
        @suggestion = attributes[:suggestion]
      end

      # Check if violation is an error
      #
      # @return [Boolean] True if severity is error
      def error?
        @severity == :error
      end

      # Check if violation is a warning
      #
      # @return [Boolean] True if severity is warning
      def warning?
        @severity == :warning
      end

      # Check if violation is info
      #
      # @return [Boolean] True if severity is info
      def info?
        @severity == :info
      end

      # Convert to hash representation
      #
      # @return [Hash] Violation as hash
      def to_h
        {
          rule_id: @rule_id,
          wcag_criterion: @wcag_criterion,
          level: @level,
          severity: @severity,
          message: @message,
          suggestion: @suggestion
        }
      end
    end
  end
end
