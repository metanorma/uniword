# frozen_string_literal: true

module Uniword
  module FindReplace
    # Aggregated result of a find-replace pass.
    #
    # Counts total substitutions and breaks the count down by scope
    # so callers can see where matches happened. Returned by
    # `Engine#run` and `DocumentRoot#find_replace`.
    #
    # @example
    #   result = engine.run
    #   result.count              # => 7
    #   result.by_scope           # => { body: 5, headers: 2 }
    #   result.scopes_touched     # => [:body, :headers]
    class Result
      attr_reader :by_scope

      def initialize
        @by_scope = Hash.new { |hash, key| hash[key] = 0 }
      end

      # Increment the count for one scope.
      #
      # @param scope [Symbol] scope name (e.g. :body, :headers)
      # @param substitutions [Integer] substitutions added
      # @return [void]
      def add(scope, substitutions)
        @by_scope[scope] += substitutions
      end

      # Total substitutions across all scopes.
      #
      # @return [Integer]
      def count
        @by_scope.values.sum
      end

      # Scopes that produced at least one substitution.
      #
      # @return [Array<Symbol>]
      def scopes_touched
        @by_scope.select { |_, c| c.positive? }.keys
      end

      # True when zero substitutions were made.
      #
      # @return [Boolean]
      def empty?
        count.zero?
      end
    end
  end
end
