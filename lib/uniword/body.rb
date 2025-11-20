# frozen_string_literal: true

require_relative 'paragraph'
require_relative 'table'
require_relative 'unknown_element'

module Uniword
  # Represents the document body containing all block-level elements
  # Responsibility: Container for paragraphs, tables, and other body elements
  #
  # The body is the main content container in a document, holding all
  # the visible content elements like paragraphs and tables.
  class Body < Lutaml::Model::Serializable
    # OOXML namespace configuration
    xml do
      root 'body', mixed: true
      namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

      map_element 'p', to: :paragraphs
      map_element 'tbl', to: :tables
    end

    # Array of paragraphs in this body
    attribute :paragraphs, Paragraph, collection: true, default: -> { [] }

    # Array of tables in this body
    attribute :tables, Table, collection: true, default: -> { [] }

    # Ordered array of all elements for maintaining insertion order
    attr_reader :ordered_elements

    # Initialize body
    def initialize(attributes = {})
      super
      @ordered_elements = []
    end

    # Add a paragraph to this body
    #
    # @param paragraph [Paragraph, UnknownElement] The paragraph to add
    # @return [Array<Paragraph>] The updated paragraphs array
    def add_paragraph(paragraph)
      # Allow UnknownElement to preserve unknown content
      unless paragraph.is_a?(Paragraph) || paragraph.is_a?(UnknownElement)
        raise ArgumentError,
              'paragraph must be a Paragraph or UnknownElement instance'
      end

      # Only add to paragraphs array if it's actually a Paragraph
      paragraphs << paragraph if paragraph.is_a?(Paragraph)
      @ordered_elements << paragraph
    end

    # Add a table to this body
    #
    # @param table [Table] The table to add
    # @return [Array<Table>] The updated tables array
    def add_table(table)
      unless table.is_a?(Table)
        raise ArgumentError,
              'table must be a Table instance'
      end

      tables << table
      @ordered_elements << table
    end

    # Get the plain text content of this body
    # Concatenates text from all paragraphs and tables
    #
    # @return [String] The combined text from all elements
    def text
      elements.map(&:text).join("\n")
    end

    # Get all elements (paragraphs and tables) in insertion order
    #
    # @return [Array<Paragraph, Table>] All body elements in order
    def elements
      @ordered_elements
    end

    # Check if body is empty
    #
    # @return [Boolean] true if empty
    def empty?
      paragraphs.empty? && tables.empty?
    end
  end
end