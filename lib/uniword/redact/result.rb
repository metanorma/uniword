# frozen_string_literal: true

module Uniword
  module Redact
    # Aggregated redaction result.
    class Result
      attr_reader :by_pattern

      def initialize
        @by_pattern = Hash.new { |h, k| h[k] = 0 }
      end

      # @param name [Symbol] pattern name
      # @param count [Integer] substitutions for this pattern
      # @return [void]
      def add(name, count)
        @by_pattern[name] += count
      end

      # Total substitutions across all patterns.
      #
      # @return [Integer]
      def count
        @by_pattern.values.sum
      end

      # Patterns that matched at least once.
      #
      # @return [Array<Symbol>]
      def patterns_matched
        @by_pattern.select { |_, c| c.positive? }.keys
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
