# frozen_string_literal: true

require "json"

module Uniword
  module Template
    # Value object holding the result of a template fill operation.
    #
    # Counts filled placeholders per source kind (content controls,
    # MERGEFIELD simple fields, {{var}} text placeholders) and records
    # the variable names that had no data. Returned by `Filler#fill`.
    #
    # @example
    #   result = Filler.new(document).fill(data)
    #   puts result.summary
    #   puts result.to_json
    class FillResult
      # Placeholder source kinds, in fill precedence order.
      SOURCES = %i[sdt mergefield text].freeze

      attr_reader :filled, :missing_counts

      def initialize
        @filled = SOURCES.to_h { |kind| [kind, 0] }
        @missing_counts = Hash.new { |hash, key| hash[key] = 0 }
      end

      # Record one filled placeholder of the given source kind.
      #
      # @param source [Symbol] one of SOURCES (e.g. :sdt, :mergefield, :text)
      # @return [void]
      def add(source)
        @filled[source] += 1
      end

      # Record one occurrence of a variable with no data.
      #
      # @param name [String] the missing variable name
      # @return [void]
      def record_missing(name)
        @missing_counts[name] += 1
      end

      # Total number of filled placeholders across all source kinds.
      #
      # @return [Integer]
      def total_filled
        @filled.values.sum
      end

      # Missing variable names, sorted alphabetically.
      #
      # @return [Array<String>]
      def missing
        @missing_counts.keys.sort
      end

      # Whether every placeholder found a value (nothing missing).
      #
      # @return [Boolean]
      def complete?
        missing.empty?
      end

      # Whether no placeholder was filled at all.
      #
      # @return [Boolean]
      def empty?
        total_filled.zero?
      end

      # Human-readable summary of the fill operation.
      #
      # @return [String]
      def summary
        parts = SOURCES.filter_map do |kind|
          count = @filled[kind]
          "#{count} #{kind} placeholder(s)" if count.positive?
        end

        summary = if parts.empty?
                    "No placeholders filled."
                  else
                    filled_summary(parts)
                  end
        summary += missing_summary if missing.any?
        summary
      end

      # Serialize to JSON string.
      #
      # @return [String] Pretty-printed JSON
      def to_json(*_args)
        JSON.pretty_generate(to_h)
      end

      # Convert to a plain Hash suitable for serialization.
      #
      # @return [Hash]
      def to_h
        {
          filled: @filled.dup,
          total_filled: total_filled,
          missing: missing,
          missing_counts: @missing_counts.dup,
          summary: summary,
        }
      end

      private

      def filled_summary(parts)
        "Filled #{total_filled} placeholder(s) (#{parts.join(', ')})."
      end

      def missing_summary
        " Missing variable(s) left untouched: #{missing.join(', ')}."
      end
    end
  end
end
