# frozen_string_literal: true

module Uniword
  module Template
    # Resolves variable expressions to values from data context.
    #
    # Handles nested property access (e.g., "chapter.number") and
    # conditional evaluation. Works with both Hash and object data sources.
    #
    # Responsibility: Variable resolution only
    # Single Responsibility Principle: Does NOT parse, render, or validate
    #
    # @example Resolve simple variable
    #   resolver = VariableResolver.new(title: "My Document")
    #   resolver.resolve("title") # => "My Document"
    #
    # @example Resolve nested property
    #   data = { chapter: { number: "5.1" } }
    #   resolver = VariableResolver.new(data)
    #   resolver.resolve("chapter.number") # => "5.1"
    #
    # @example Resolve from object
    #   class Chapter
    #     attr_reader :number
    #     def initialize(num)
    #       @number = num
    #     end
    #   end
    #   resolver = VariableResolver.new(Chapter.new("5.1"))
    #   resolver.resolve("number") # => "5.1"
    class VariableResolver
      # Initialize resolver with data context
      #
      # @param data [Hash, Object] Data source for variable resolution
      # @param context [Hash] Additional context variables
      def initialize(data, context = {})
        @data = data
        @context = context
      end

      # Resolve variable expression to value
      #
      # Supports dot notation for nested properties:
      # - "title" => @data[:title] or @data.title
      # - "chapter.number" => @data[:chapter][:number] or @data.chapter.number
      #
      # @param expression [String] Variable expression (e.g., "title", "chapter.number")
      # @return [Object] Resolved value or nil if not found
      def resolve(expression)
        return nil if expression.nil? || expression.empty?

        parts = expression.to_s.split('.')

        # Start with root data
        value = @data

        # Navigate through each part
        parts.each do |part|
          break if value.nil?
          value = navigate_property(value, part)
        end

        value
      end

      # Evaluate conditional expression
      #
      # Supports:
      # - Simple truthiness: "has_annexes"
      # - Comparisons: "count > 5", "status == 'active'"
      #
      # @param condition [String] Condition expression
      # @return [Boolean] Evaluation result
      def evaluate(condition)
        return false if condition.nil? || condition.empty?

        # Simple variable existence/truthiness check
        if condition.match?(/^\w+(\.\w+)*$/)
          value = resolve(condition)
          return !!value
        end

        # Comparison operators - order matters, check >= and <= before > and <
        match = condition.match(/(.+?)\s*(>=|<=|==|!=|>|<)\s*(.+)/)
        if match
          left_expr = match[1].strip
          operator = match[2]
          right_expr = match[3].strip

          left = resolve(left_expr)
          right = parse_literal(right_expr)

          evaluate_comparison(left, operator, right)
        else
          false
        end
      end

      private

      # Navigate to a property on an object
      #
      # @param object [Object] Object to navigate
      # @param property [String] Property name
      # @return [Object] Property value or nil
      def navigate_property(object, property)
        # For hashes, use key access
        if object.is_a?(Hash)
          object[property.to_sym] || object[property]
        # For objects with methods, call the method
        elsif object.respond_to?(property.to_sym)
          object.send(property.to_sym)
        else
          nil
        end
      end

      # Parse literal value from string
      #
      # @param value [String] Literal value string
      # @return [Object] Parsed value (number, string, etc.)
      def parse_literal(value)
        # Remove quotes if present
        match = value.match(/^["'](.*)["']$/)
        if match
          match[1]
        elsif value.match?(/^\d+$/)
          value.to_i
        elsif value.match?(/^\d+\.\d+$/)
          value.to_f
        elsif value == 'true'
          true
        elsif value == 'false'
          false
        elsif value == 'nil'
          nil
        else
          # Try to resolve as variable
          resolve(value) || value
        end
      end

      # Evaluate comparison between two values
      #
      # @param left [Object] Left operand
      # @param operator [String] Comparison operator
      # @param right [Object] Right operand
      # @return [Boolean] Comparison result
      def evaluate_comparison(left, operator, right)
        case operator
        when '=='
          left == right
        when '!='
          left != right
        when '>'
          compare_numerically(left, right, :>)
        when '<'
          compare_numerically(left, right, :<)
        when '>='
          compare_numerically(left, right, :>=)
        when '<='
          compare_numerically(left, right, :<=)
        else
          false
        end
      end

      # Compare values numerically
      #
      # @param left [Object] Left operand
      # @param right [Object] Right operand
      # @param operator [Symbol] Comparison operator
      # @return [Boolean] Comparison result
      def compare_numerically(left, right, operator)
        left_num = to_number(left)
        right_num = to_number(right)

        return false if left_num.nil? || right_num.nil?

        left_num.send(operator, right_num)
      end

      # Convert value to number
      #
      # @param value [Object] Value to convert
      # @return [Numeric, nil] Numeric value or nil
      def to_number(value)
        return value if value.is_a?(Numeric)
        return value.to_i if value.respond_to?(:to_i) && value.to_s.match?(/^\d+$/)
        return value.to_f if value.respond_to?(:to_f) && value.to_s.match?(/^\d+\.\d+$/)
        nil
      end
    end
  end
end