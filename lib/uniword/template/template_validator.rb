# frozen_string_literal: true

module Uniword
  module Template
    # Validates template structure and syntax.
    #
    # Checks for common template errors:
    # - Unclosed loops ({{@each}} without {{@end}})
    # - Unclosed conditionals ({{@if}} without {{@end}})
    # - Mismatched nesting
    # - Invalid syntax
    #
    # Responsibility: Template validation only
    # Single Responsibility Principle: Does NOT parse or render
    #
    # @example Validate template
    #   validator = TemplateValidator.new(template)
    #   errors = validator.validate
    #   if errors.any?
    #     puts "Template errors:"
    #     errors.each { |e| puts "  - #{e}" }
    #   end
    class TemplateValidator
      # Initialize validator
      #
      # @param template [Template] Template to validate
      def initialize(template)
        @template = template
        @errors = []
      end

      # Validate template
      #
      # @return [Array<String>] Validation errors (empty if valid)
      def validate
        @errors = []

        validate_loop_nesting
        validate_conditional_nesting
        validate_marker_syntax

        @errors
      end

      private

      # Validate loop nesting
      #
      # Checks that all {{@each}} have matching {{@end}}
      #
      # @return [void]
      def validate_loop_nesting
        depth = 0
        loop_stack = []

        @template.markers.each do |marker|
          case marker.type
          when :loop_start
            depth += 1
            loop_stack.push(marker)
          when :loop_end
            depth -= 1
            loop_stack.pop

            if depth.negative?
              @errors << "Unmatched {{@end}} at position #{marker.position} " \
                         "without corresponding {{@each}}"
            end
          end
        end

        # Check for unclosed loops
        return unless depth.positive?

        loop_stack.each do |unclosed|
          @errors << "Unclosed loop {{@each #{unclosed.collection}}} " \
                     "at position #{unclosed.position}: missing {{@end}}"
        end
      end

      # Validate conditional nesting
      #
      # Checks that all {{@if}} have matching {{@end}}
      #
      # @return [void]
      def validate_conditional_nesting
        # Separate tracking for conditionals since they share {{@end}} with loops
        conditional_stack = []

        @template.markers.each do |marker|
          case marker.type
          when :conditional_start
            conditional_stack.push(marker)
          when :loop_end
            # Could be closing a conditional
            next if conditional_stack.empty?

            # Check if this {{@end}} could be closing a conditional
            # This is a simplified check - more sophisticated logic would track
            # the nesting hierarchy properly
            conditional_stack.pop if should_close_conditional?(marker, conditional_stack.last)
          end
        end

        # Check for unclosed conditionals
        conditional_stack.each do |unclosed|
          @errors << "Unclosed conditional {{@if #{unclosed.condition}}} " \
                     "at position #{unclosed.position}: missing {{@end}}"
        end
      end

      # Check if end marker should close conditional
      #
      # @param end_marker [TemplateMarker] End marker
      # @param conditional [TemplateMarker] Conditional start marker
      # @return [Boolean] true if should close
      def should_close_conditional?(end_marker, conditional)
        # Simple heuristic: if end marker is after conditional and before next loop
        return false unless end_marker && conditional

        end_marker.position > conditional.position
      end

      # Validate marker syntax
      #
      # Checks for invalid or malformed markers
      #
      # @return [void]
      def validate_marker_syntax
        @template.markers.each do |marker|
          case marker.type
          when :variable
            validate_variable_expression(marker)
          when :loop_start
            validate_loop_collection(marker)
          when :conditional_start
            validate_conditional_expression(marker)
          end
        end
      end

      # Validate variable expression
      #
      # @param marker [TemplateMarker] Variable marker
      # @return [void]
      def validate_variable_expression(marker)
        expr = marker.expression

        if expr.nil? || expr.strip.empty?
          @errors << "Empty variable expression at position #{marker.position}"
          return
        end

        # Check for valid identifier syntax
        return if expr.match?(/^[a-zA-Z_]\w*(\.[a-zA-Z_]\w*)*$/)

        @errors << "Invalid variable expression '#{expr}' at position #{marker.position}. " \
                   "Expected format: variable or object.property"
      end

      # Validate loop collection
      #
      # @param marker [TemplateMarker] Loop marker
      # @return [void]
      def validate_loop_collection(marker)
        collection = marker.collection

        if collection.nil? || collection.strip.empty?
          @errors << "Empty collection name in {{@each}} at position #{marker.position}"
          return
        end

        # Check for valid identifier syntax
        return if collection.match?(/^[a-zA-Z_]\w*(\.[a-zA-Z_]\w*)*$/)

        @errors << "Invalid collection name '#{collection}' at position #{marker.position}. " \
                   "Expected format: collection or object.collection"
      end

      # Validate conditional expression
      #
      # @param marker [TemplateMarker] Conditional marker
      # @return [void]
      def validate_conditional_expression(marker)
        condition = marker.condition

        if condition.nil? || condition.strip.empty?
          @errors << "Empty condition in {{@if}} at position #{marker.position}"
          return
        end

        # Basic syntax check - more sophisticated validation could be added
        # Allow: variable, object.property, comparisons
        valid_pattern = /^[\w.]+(\s*(==|!=|>|<|>=|<=)\s*[\w."']+)?$/

        return if condition.match?(valid_pattern)

        @errors << "Invalid condition syntax '#{condition}' at position #{marker.position}"
      end
    end
  end
end
