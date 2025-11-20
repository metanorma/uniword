# frozen_string_literal: true

module Uniword
  module Template
    # Represents a template marker extracted from Word comments.
    #
    # A marker is an instruction embedded in a Word document comment that
    # tells the template engine how to process content (variable substitution,
    # loops, conditionals).
    #
    # Marker Types:
    # - :variable - Simple variable substitution {{variable_name}}
    # - :loop_start - Start of repeating section {{@each collection}}
    # - :loop_end - End of repeating section {{@end}}
    # - :conditional_start - Start of conditional {{@if condition}}
    # - :conditional_end - End of conditional {{@end}}
    #
    # @example Variable marker
    #   marker = TemplateMarker.new(
    #     type: :variable,
    #     expression: 'title',
    #     element: paragraph,
    #     position: 0
    #   )
    #
    # @example Loop marker
    #   marker = TemplateMarker.new(
    #     type: :loop_start,
    #     collection: 'clauses',
    #     element: paragraph,
    #     position: 5
    #   )
    #
    # @attr_reader [Symbol] type Marker type
    # @attr_reader [String] collection Collection name for loops
    # @attr_reader [String] condition Condition expression for conditionals
    # @attr_reader [String] expression Variable expression
    # @attr_reader [Element] element The document element this marker is attached to
    # @attr_reader [Integer] position Document position for sorting
    class TemplateMarker
      attr_reader :type, :collection, :condition, :expression,
                  :element, :position

      # Initialize a template marker
      #
      # @param attributes [Hash] Marker attributes
      # @option attributes [Symbol] :type Marker type
      # @option attributes [String] :collection Collection name (for loops)
      # @option attributes [String] :condition Condition (for conditionals)
      # @option attributes [String] :expression Variable expression
      # @option attributes [Element] :element Document element
      # @option attributes [Integer] :position Document position
      def initialize(attributes)
        @type = attributes[:type]
        @collection = attributes[:collection]
        @condition = attributes[:condition]
        @expression = attributes[:expression]
        @element = attributes[:element]
        @position = attributes[:position]
      end

      # Check if marker is a loop start
      #
      # @return [Boolean] true if loop start
      def loop_start?
        @type == :loop_start
      end

      # Check if marker is a loop end
      #
      # @return [Boolean] true if loop end
      def loop_end?
        @type == :loop_end
      end

      # Check if marker is a conditional start
      #
      # @return [Boolean] true if conditional start
      def conditional_start?
        @type == :conditional_start
      end

      # Check if marker is a conditional end
      #
      # @return [Boolean] true if conditional end
      def conditional_end?
        @type == :conditional_end
      end

      # Check if marker is a variable
      #
      # @return [Boolean] true if variable
      def variable?
        @type == :variable
      end

      # Get marker name for display
      #
      # @return [String] Marker name
      def name
        case @type
        when :variable
          @expression
        when :loop_start
          @collection
        when :conditional_start
          @condition
        else
          @type.to_s
        end
      end

      # Inspect marker for debugging
      #
      # @return [String] Readable representation
      def inspect
        "#<TemplateMarker type=#{@type} name=#{name.inspect} position=#{@position}>"
      end
    end
  end
end