# frozen_string_literal: true

module Uniword
  module Toc
    # Value object representing a single entry in a Table of Contents.
    #
    # Each entry corresponds to a heading paragraph found in the document.
    # Holds the heading level, text, page number (if known), style name,
    # and the paragraph index within the document body.
    #
    # @example Create a TOC entry
    #   entry = TocEntry.new(
    #     level: 1,
    #     text: "Introduction",
    #     style_name: "Heading1",
    #     paragraph_index: 3
    #   )
    class TocEntry
      # @return [Integer] Heading level (1-6)
      attr_reader :level

      # @return [String] Heading text content
      attr_reader :text

      # @return [Integer, nil] Page number (populated by Word after update)
      attr_reader :page

      # @return [String, nil] Style name that produced this entry
      attr_reader :style_name

      # @return [Integer, nil] Index of the paragraph in the document body
      attr_reader :paragraph_index

      # Initialize a TOC entry.
      #
      # @param level [Integer] Heading level (1-6)
      # @param text [String] Heading text content
      # @param page [Integer, nil] Page number, if known
      # @param style_name [String, nil] Paragraph style name
      # @param paragraph_index [Integer, nil] Index of the source paragraph
      def initialize(level:, text:, page: nil, style_name: nil,
                     paragraph_index: nil)
        @level = level
        @text = text
        @page = page
        @style_name = style_name
        @paragraph_index = paragraph_index
      end

      # Human-readable representation.
      #
      # @return [String]
      def to_s
        indent = "  " * (level - 1)
        page_str = page ? " (p.#{page})" : ""
        "#{indent}#{text}#{page_str}"
      end

      # Convert to a hash suitable for JSON output.
      #
      # @return [Hash]
      def to_h
        {
          level: level,
          text: text,
          page: page,
          style_name: style_name,
          paragraph_index: paragraph_index
        }
      end
    end
  end
end
