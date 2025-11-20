# frozen_string_literal: true

module Uniword
  module Template
    # Manages rendering context and scope during template processing.
    #
    # Handles nested scopes for loops and maintains the current data context.
    # Provides clean scope isolation for loop iterations.
    #
    # Responsibility: Context management only
    # Single Responsibility Principle: Does NOT parse, render, or resolve
    #
    # @example Simple context
    #   context = TemplateContext.new(title: "My Document")
    #   context.current_data # => {title: "My Document"}
    #
    # @example Nested context for loop
    #   context = TemplateContext.new(chapters: [...])
    #   context.push_scope(chapters.first)
    #   # Now context.current_data is the first chapter
    #   context.pop_scope
    #   # Back to original context
    class TemplateContext
      attr_reader :root_data, :additional_context

      # Initialize context with data
      #
      # @param root_data [Hash, Object] Root data object
      # @param additional_context [Hash] Additional context variables
      def initialize(root_data, additional_context = {})
        @root_data = root_data
        @additional_context = additional_context
        @scope_stack = [root_data]
      end

      # Get current data scope
      #
      # @return [Object] Current scope data
      def current_data
        @scope_stack.last
      end

      # Push new scope onto stack
      #
      # Used when entering a loop or conditional block to create
      # a new data context.
      #
      # @param scope_data [Object] Data for new scope
      # @return [Object] The pushed scope data
      def push_scope(scope_data)
        @scope_stack.push(scope_data)
        scope_data
      end

      # Pop scope from stack
      #
      # Returns to previous scope level.
      #
      # @return [Object] The popped scope data
      def pop_scope
        # Always keep at least root scope
        return nil if @scope_stack.size <= 1

        @scope_stack.pop
      end

      # Get current scope depth
      #
      # @return [Integer] Number of nested scopes
      def depth
        @scope_stack.size
      end

      # Check if in nested scope
      #
      # @return [Boolean] true if depth > 1
      def nested?
        depth > 1
      end

      # Create resolver for current scope
      #
      # @return [VariableResolver] Resolver with current context
      def create_resolver
        require_relative 'variable_resolver'
        VariableResolver.new(current_data, @additional_context)
      end

      # Reset context to root scope
      #
      # @return [void]
      def reset
        @scope_stack = [@root_data]
      end

      # Inspect context for debugging
      #
      # @return [String] Readable representation
      def inspect
        "#<TemplateContext depth=#{depth} current=#{current_data.class.name}>"
      end
    end
  end
end