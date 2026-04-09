# frozen_string_literal: true

module Uniword
  # Imports HTML content and converts it to OOXML paragraphs or documents.
  #
  # @example Import simple HTML
  #   paragraphs = Uniword::HtmlImporter.import('<p>Hello World</p>')
  #
  # @example Import with new instance
  #   importer = Uniword::HtmlImporter.new('<p>Hello</p>')
  #   doc = importer.to_document
  #
  # @example Class method import
  #   paragraphs = Uniword::HtmlImporter.import('<p>Hello</p>')
  class HtmlImporter
    # @return [String] The HTML content being imported
    attr_reader :html

    # Create a new HtmlImporter instance
    #
    # @param html [String] HTML content to import
    def initialize(html = nil)
      @html = html
    end

    # Import HTML content and convert to OOXML paragraphs
    #
    # @param html [String] HTML content (overrides instance html if provided)
    # @return [Array<Uniword::Wordprocessingml::Paragraph>]
    def import(html = nil)
      content = html || @html
      Transformation::HtmlToOoxmlConverter.html_to_paragraphs(content)
    end

    # Convert imported HTML to a DocumentRoot
    #
    # @return [Uniword::Wordprocessingml::DocumentRoot]
    def to_document
      doc = Wordprocessingml::DocumentRoot.new
      paragraphs = import
      paragraphs.each do |para|
        doc.body.paragraphs << para
      end
      doc
    end

    # Class method: Import HTML content
    #
    # @param html [String] HTML content
    # @return [Array<Uniword::Wordprocessingml::Paragraph>]
    def self.import(html)
      new.import(html)
    end
  end
end
