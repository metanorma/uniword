# frozen_string_literal: true

module Uniword
  module Accessibility
    # Accessibility Rule - base class for all accessibility rules
    #
    # Responsibility: Define rule interface and common functionality
    # Single Responsibility: Rule interface and violation creation only
    #
    # @abstract Subclass and implement {#check} to create a rule
    #
    # @example Implementing a custom rule
    #   class MyCustomRule < AccessibilityRule
    #     def check(document)
    #       violations = []
    #       # Check logic here
    #       violations << create_violation(...) if issue_found
    #       violations
    #     end
    #   end
    class AccessibilityRule
      attr_reader :rule_id, :wcag_criterion, :level, :config

      # Initialize a new accessibility rule
      #
      # @param config [Hash] Rule configuration from profile
      # @option config [String] :wcag_criterion WCAG criterion number
      # @option config [String] :level WCAG level (A, AA, AAA)
      # @option config [Boolean] :enabled Whether rule is enabled
      # @option config [Symbol] :severity Default severity level
      def initialize(config)
        @config = config || {}
        @rule_id = derive_rule_id
        @wcag_criterion = @config[:wcag_criterion]
        @level = @config[:level]
      end

      # Check if rule is enabled
      #
      # @return [Boolean] True if rule is enabled
      def enabled?
        @config.fetch(:enabled, true)
      end

      # Check document against rule
      #
      # @param document [Document] Document to check
      # @return [Array<AccessibilityViolation>] Found violations
      # @raise [NotImplementedError] If not implemented by subclass
      def check(document)
        raise NotImplementedError, "#{self.class} must implement #check"
      end

      protected

      # Create a new accessibility violation
      #
      # @param message [String] Violation message
      # @param element [Object] Element with violation
      # @param severity [Symbol] Severity level (:error, :warning, :info)
      # @param suggestion [String] Fix suggestion
      # @return [AccessibilityViolation] New violation instance
      def create_violation(message:, element:, severity:, suggestion:)
        AccessibilityViolation.new(
          rule_id: @rule_id,
          wcag_criterion: @wcag_criterion,
          level: @level,
          message: message,
          element: element,
          severity: severity,
          suggestion: suggestion,
        )
      end

      private

      # Derive rule ID from class name
      #
      # @return [Symbol] Rule identifier
      # @example
      #   ImageAltTextRule => :image_alt_text
      def derive_rule_id
        self.class.name
          .split("::")
          .last
          .gsub("Rule", "")
          .gsub(/([A-Z])/) { |m| "_#{m.downcase}" }
          .sub(/^_/, "")
          .to_sym
      end
    end
  end
end
