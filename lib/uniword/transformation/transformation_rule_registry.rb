# frozen_string_literal: true

module Uniword
  module Transformation
    # Registry for transformation rules.
    #
    # Responsibility: Manage registration and lookup of transformation rules.
    # Single Responsibility - only handles rule registration and retrieval.
    #
    # Follows Open/Closed Principle - new rules can be registered without
    # modifying this class.
    #
    # Follows MECE Principle - each rule is mutually exclusive (handles
    # specific element types and format combinations), and collectively
    # exhaustive (fallback to NullTransformationRule ensures coverage).
    #
    # @example Register and use rules
    #   registry = TransformationRuleRegistry.new
    #   registry.register(ParagraphTransformationRule.new(
    #     source_format: :docx,
    #     target_format: :mhtml
    #   ))
    #
    #   rule = registry.find_rule(
    #     element_type: Paragraph,
    #     source_format: :docx,
    #     target_format: :mhtml
    #   )
    class TransformationRuleRegistry
      # Initialize empty registry
      def initialize
        @rules = []
        @null_rule = NullTransformationRule.new
      end

      # Register a transformation rule
      #
      # @param rule [TransformationRule] The rule to register
      # @return [self] Returns self for method chaining
      # @raise [ArgumentError] if rule is not a TransformationRule
      #
      # @example Register a rule
      #   registry.register(CustomRule.new(source_format: :docx, target_format: :mhtml))
      def register(rule)
        validate_rule(rule)
        @rules << rule
        self
      end

      # Find a rule matching the given criteria
      #
      # Returns the first matching rule, or NullTransformationRule if none match.
      # NullTransformationRule returns element unchanged (deep copy).
      #
      # @param element_type [Class] The element class to transform
      # @param source_format [Symbol] Source format (:docx or :mhtml)
      # @param target_format [Symbol] Target format (:docx or :mhtml)
      # @return [TransformationRule] The matching rule or NullTransformationRule
      #
      # @example Find a rule
      #   rule = registry.find_rule(
      #     element_type: Paragraph,
      #     source_format: :docx,
      #     target_format: :mhtml
      #   )
      def find_rule(element_type:, source_format:, target_format:)
        @rules.find do |rule|
          rule.matches?(
            element_type: element_type,
            source_format: source_format,
            target_format: target_format
          )
        end || @null_rule
      end

      # Get all registered rules
      #
      # @return [Array<TransformationRule>] Array of registered rules
      def rules
        @rules.dup
      end

      # Get count of registered rules
      #
      # @return [Integer] Number of registered rules
      def count
        @rules.count
      end

      # Check if any rules are registered
      #
      # @return [Boolean] true if registry has rules
      def empty?
        @rules.empty?
      end

      # Clear all registered rules
      #
      # Useful for testing or reconfiguration
      #
      # @return [self] Returns self for method chaining
      def clear
        @rules.clear
        self
      end

      # Register multiple rules at once
      #
      # @param rules [Array<TransformationRule>] Array of rules to register
      # @return [self] Returns self for method chaining
      #
      # @example Batch registration
      #   registry.register_all([rule1, rule2, rule3])
      def register_all(rules)
        rules.each { |rule| register(rule) }
        self
      end

      private

      # Validate that object is a TransformationRule
      #
      # @param rule [Object] Object to validate
      # @raise [ArgumentError] if rule is invalid
      def validate_rule(rule)
        return if rule.is_a?(TransformationRule)

        raise ArgumentError,
              "Rule must be a TransformationRule, got #{rule.class}"
      end
    end
  end
end
