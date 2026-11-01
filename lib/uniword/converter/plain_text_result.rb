# frozen_string_literal: true

require "json"

module Uniword
  module Converter
    # Value object describing the outcome of a plain-text conversion
    # (Converter::PlainText).
    #
    # Records how many blocks of each kind were converted and which
    # document features were dropped or degraded on the way, so callers
    # (and the CLI --json output) can surface the fidelity boundary
    # explicitly instead of losing content silently.
    #
    # @example
    #   result = converter.to_markdown_result(document)
    #   puts result.summary
    #   result.dropped?("comments") # => true
    class PlainTextResult
      # The target or source plain-text format (:markdown or :asciidoc)
      attr_reader :format

      # The conversion direction, e.g. :docx_to_markdown
      attr_reader :direction

      # Converted block counts (e.g. { headings: 2, paragraphs: 3 })
      attr_reader :block_counts

      # Features dropped or degraded during the conversion
      attr_reader :dropped_features

      # Converted plain text (to_* conversions; nil otherwise)
      attr_reader :text

      # Converted document model (from_* conversions; nil otherwise)
      attr_reader :document

      # Initialize a conversion result.
      #
      # @param format [Symbol] :markdown or :asciidoc
      # @param direction [Symbol] e.g. :docx_to_markdown
      # @param block_counts [Hash<Symbol, Integer>] converted block counts
      # @param dropped_features [Array<String>] dropped/degraded features
      # @param text [String, nil] converted plain text
      # @param document [Wordprocessingml::DocumentRoot, nil] converted model
      def initialize(format:, direction:, block_counts: {},
                     dropped_features: [], text: nil, document: nil)
        @format = format
        @direction = direction
        @block_counts = block_counts
        @dropped_features = dropped_features
        @text = text
        @document = document
      end

      # Whether a feature was dropped or degraded.
      #
      # @param feature [String] feature name as recorded in dropped_features
      # @return [Boolean]
      def dropped?(feature)
        dropped_features.include?(feature)
      end

      # Whether nothing was dropped or degraded.
      #
      # @return [Boolean]
      def clean?
        dropped_features.empty?
      end

      # Total number of converted blocks.
      #
      # @return [Integer]
      def total_blocks
        block_counts.values.sum
      end

      # Human-readable summary of the conversion.
      #
      # @return [String]
      def summary
        parts = block_counts.filter_map do |kind, count|
          "#{count} #{kind}" if count.positive?
        end
        summary = "#{direction}: converted #{parts.join(', ')}"
        summary += "; dropped: #{dropped_features.join(', ')}" unless clean?
        summary
      end

      # Serialize to a JSON string.
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
          format: format,
          direction: direction,
          blocks: block_counts,
          total_blocks: total_blocks,
          dropped_features: dropped_features,
          summary: summary,
        }
      end
    end
  end
end
