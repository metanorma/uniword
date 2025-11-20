# frozen_string_literal: true

module Uniword
  # Represents a footnote in a document.
  #
  # Responsibility: Store footnote content and metadata. Footnotes appear
  # at the bottom of the page where they are referenced.
  #
  # A footnote consists of:
  # - An ID that uniquely identifies it
  # - Content (array of paragraphs)
  #
  # @example Create a footnote
  #   footnote = Uniword::Footnote.new(
  #     id: 1,
  #     content: [paragraph1, paragraph2]
  #   )
  #
  # @example Access footnote properties
  #   footnote.id       # => 1
  #   footnote.content  # => [paragraph1, paragraph2]
  class Footnote
    # @return [Integer, String] The unique identifier for this footnote
    attr_accessor :id

    # @return [Array<Paragraph>] The content paragraphs of the footnote
    attr_accessor :content

    # Initialize a new Footnote.
    #
    # @param id [Integer, String] The unique identifier
    # @param content [Array<Paragraph>] The footnote content paragraphs
    #
    # @example Create a footnote
    #   footnote = Footnote.new(id: 1, content: [paragraph])
    def initialize(id:, content: [])
      @id = id
      @content = content
    end

    # Check if footnote has content.
    #
    # @return [Boolean] true if footnote has content
    def content?
      !@content.nil? && !@content.empty?
    end

    # Add a paragraph to the footnote content.
    #
    # @param paragraph [Paragraph] The paragraph to add
    # @return [void]
    #
    # @example Add content to footnote
    #   footnote.add_paragraph(paragraph)
    def add_paragraph(paragraph)
      @content << paragraph
    end

    # Get text content of footnote.
    #
    # @return [String] The combined text of all paragraphs
    def text
      @content.map { |p| p.respond_to?(:text) ? p.text : p.to_s }.join("\n")
    end

    # Convert to hash representation.
    #
    # @return [Hash] Hash representation of the footnote
    def to_h
      {
        id: @id,
        content: @content
      }
    end
  end
end