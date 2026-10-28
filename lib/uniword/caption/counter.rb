# frozen_string_literal: true

module Uniword
  module Caption
    # Label-keyed counter for figure/table/equation captions.
    # Persisted on the document via `DocumentRoot#caption_counters`;
    # each label starts at 1 and increments on every `next_value`.
    #
    # Open/closed: any label string works — adding a new label
    # category is just using it.
    class Counter
      # @return [Hash{String => Integer}]
      attr_reader :counts

      def initialize
        @counts = Hash.new { |h, k| h[k] = 0 }
      end

      # @param label [String] e.g. "Figure", "Table", "Equation"
      # @return [Integer] the next sequence value for this label
      def next_value(label)
        label = normalize_label(label)
        @counts[label] += 1
      end

      # Current count without incrementing.
      #
      # @param label [String]
      # @return [Integer]
      def current(label)
        @counts[normalize_label(label)]
      end

      # Reset one or all counters.
      #
      # @param label [String, nil] nil resets all
      # @return [void]
      def reset(label = nil)
        if label.nil?
          @counts.clear
          return
        end

        @counts.delete(normalize_label(label))
      end

      # All labels currently tracked.
      #
      # @return [Array<String>]
      def labels
        @counts.keys
      end

      private

      def normalize_label(label)
        label.to_s
      end
    end
  end
end
