# frozen_string_literal: true

module Uniword
  # Represents an endnote in a document.
  #
  # Responsibility: Store endnote content and metadata. Endnotes appear
  # at the end of the document or section, unlike footnotes which appear
  # at the bottom of each page.
  #
  # An endnote consists of:
  # - An ID that uniquely identifies it
  # - Content (array of paragraphs)
  #
  # @example Create an endnote
  #   endnote = Uniword::Endnote.new(
  #     id: 1,
  #     content: [paragraph1, paragraph2]
  #   )
  #
  # @example Access endnote properties
  #   endnote.id       # => 1
  #   endnote.content  # => [paragraph1, paragraph2]
  class Endnote
    # @return [Integer, String] The unique identifier for this endnote
    attr_accessor :id

    # @return [Array<Paragraph>] The content paragraphs of the endnote
    attr_accessor :content

    # Initialize a new Endnote.
    #
    # @param id [Integer, String] The unique identifier
    # @param content [Array<Paragraph>] The endnote content paragraphs
    #
    # @example Create an endnote
    #   endnote = Endnote.new(id: 1, content: [paragraph])
    def initialize(id:, content: [])
      @id = id
      @content = content
    end

    # Check if endnote has content.
    #
    # @return [Boolean] true if endnote has content
    def content?
      !@content.nil? && !@content.empty?
    end

    # Add a paragraph to the endnote content.
    #
    # @param paragraph [Paragraph] The paragraph to add
    # @return [void]
    #
    # @example Add content to endnote
    #   endnote.add_paragraph(paragraph)
    def add_paragraph(paragraph)
      @content << paragraph
    end

    # Get text content of endnote.
    #
    # @return [String] The combined text of all paragraphs
    def text
      @content.map { |p| p.respond_to?(:text) ? p.text : p.to_s }.join("\n")
    end

    # Convert to hash representation.
    #
    # @return [Hash] Hash representation of the endnote
    def to_h
      {
        id: @id,
        content: @content
      }
    end
  end
end
