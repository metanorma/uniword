# frozen_string_literal: true

module Uniword
  module Transformation
    # Base class for transformation rules.
    #
    # Responsibility: Define the interface for element transformation rules.
    # Each rule transforms one element type from source format to target format.
    #
    # Follows Single Responsibility Principle - one rule handles one transformation pattern.
    # Follows Open/Closed Principle - new rules can be added without modifying this class.
    #
    # @example Create a custom transformation rule
    #   class CustomRule < TransformationRule
    #     def matches?(element_type:, source_format:, target_format:)
    #       element_type == CustomElement &&
    #         source_format == :docx &&
    #         target_format == :mhtml
    #     end
    #
    #     def transform(element)
    #       # Transform CustomElement from DOCX to MHTML format
    #       transformed = CustomElement.new
    #       # Copy and adapt properties
    #       transformed
    #     end
    #   end
    class TransformationRule
      attr_reader :source_format, :target_format

      # Initialize transformation rule
      #
      # @param source_format [Symbol] Source format (:docx or :mhtml)
      # @param target_format [Symbol] Target format (:docx or :mhtml)
      def initialize(source_format:, target_format:)
        @source_format = source_format
        @target_format = target_format
      end

      # Check if this rule matches the transformation request
      #
      # @param element_type [Class] The element class to transform
      # @param source_format [Symbol] Source format
      # @param target_format [Symbol] Target format
      # @return [Boolean] true if this rule can handle the transformation
      def matches?(element_type:, source_format:, target_format:)
        raise NotImplementedError, "#{self.class} must implement #matches?"
      end

      # Transform an element from source format to target format
      #
      # @param element [Element] The element to transform
      # @return [Element, Array<Element>] The transformed element(s)
      def transform(element)
        raise NotImplementedError, "#{self.class} must implement #transform"
      end

      protected

      # Helper to validate element type
      #
      # @param element [Object] Element to validate
      # @param expected_type [Class] Expected class
      # @raise [ArgumentError] if element is wrong type
      def validate_element_type(element, expected_type)
        return if element.is_a?(expected_type)

        raise ArgumentError,
              "Expected #{expected_type}, got #{element.class}"
      end
    end

    # Null transformation rule (fallback when no rule matches)
    #
    # Returns element unchanged - useful as default behavior
    class NullTransformationRule < TransformationRule
      def initialize
        super(source_format: :any, target_format: :any)
      end

      def matches?(element_type:, source_format:, target_format:)
        true # Matches anything (fallback)
      end

      def transform(element)
        # No transformation - deep copy element to avoid mutations
        element.class.new(element.to_h)
      end
    end
  end
end
