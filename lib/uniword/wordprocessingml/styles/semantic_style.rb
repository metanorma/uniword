# frozen_string_literal: true

module Uniword
  module Styles
    # Semantic style definition
    #
    # Responsibility: Hold semantic style properties
    # Single Responsibility: Semantic style configuration only
    #
    # Extends paragraph styles with semantic meaning for special
    # content types like terms, definitions, examples, notes, etc.
    class SemanticStyle < ParagraphStyleDefinition
      attr_reader :semantic_type

      SEMANTIC_TYPES = %i[
        term
        definition
        example
        note
        warning
        caution
        code_example
        formula
        reference
      ].freeze

      def initialize(config)
        super
        @semantic_type = config[:semantic]&.to_sym
        validate_semantic_type!
      end

      # Check if this is a valid semantic style
      #
      # @return [Boolean] True if semantic type is valid
      def valid_semantic?
        SEMANTIC_TYPES.include?(@semantic_type)
      end

      # Get all properties including semantic type
      #
      # @return [Hash] All style properties including semantic type
      def full_properties
        super.merge(semantic: @semantic_type)
      end

      private

      def validate_semantic_type!
        return unless @semantic_type && !valid_semantic?

        raise ArgumentError,
              "Invalid semantic type: #{@semantic_type}. " \
              "Must be one of: #{SEMANTIC_TYPES.join(", ")}"
      end
    end
  end
end
