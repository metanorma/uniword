# frozen_string_literal: true

require "json"

module Uniword
  module Diff
    # Value object holding the result of comparing two documents.
    #
    # Contains arrays of text, formatting, structural, metadata, and style
    # changes discovered during a diff operation. Use #empty? to check if
    # the two documents are identical.
    #
    # @example
    #   result = DocumentDiffer.new(old_doc, new_doc).diff
    #   puts result.summary
    #   puts result.to_json
    class DiffResult
      attr_reader :text_changes, :format_changes,
                  :structure_changes, :metadata_changes,
                  :style_changes

      # Initialize a DiffResult with change arrays.
      #
      # @param text_changes [Array<Hash>] Text-level diffs
      # @param format_changes [Array<Hash>] Formatting diffs
      # @param structure_changes [Array<Hash>] Structural diffs
      # @param metadata_changes [Hash] Changed metadata fields
      # @param style_changes [Array<Hash>] Style definition diffs
      def initialize(text_changes: [],
                     format_changes: [],
                     structure_changes: [],
                     metadata_changes: {},
                     style_changes: [])
        @text_changes = text_changes
        @format_changes = format_changes
        @structure_changes = structure_changes
        @metadata_changes = metadata_changes
        @style_changes = style_changes
      end

      # Whether the documents are identical (no changes of any kind).
      #
      # @return [Boolean]
      def empty?
        text_changes.empty? &&
          format_changes.empty? &&
          structure_changes.empty? &&
          metadata_changes.empty? &&
          style_changes.empty?
      end

      # Total number of changes across all categories.
      #
      # @return [Integer]
      def total_changes
        text_changes.size +
          format_changes.size +
          structure_changes.size +
          metadata_changes.size +
          style_changes.size
      end

      # Human-readable summary of changes.
      #
      # @return [String]
      def summary
        return "No differences found." if empty?

        parts = []
        parts << "#{text_changes.size} text change(s)" if text_changes.any?
        parts << "#{format_changes.size} format change(s)" if format_changes.any?
        parts << "#{structure_changes.size} structural change(s)" if structure_changes.any?
        parts << "#{metadata_changes.size} metadata change(s)" if metadata_changes.any?
        parts << "#{style_changes.size} style change(s)" if style_changes.any?
        parts.join(", ")
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
          text_changes: text_changes,
          format_changes: format_changes,
          structure_changes: structure_changes,
          metadata_changes: metadata_changes,
          style_changes: style_changes,
          summary: summary,
        }
      end
    end
  end
end
