# frozen_string_literal: true

require_relative 'lazy_loader'
require_relative 'properties/table_properties'

module Uniword
  # Represents a table cell
  # Responsibility: Hold cell content (paragraphs) and cell-level formatting
  #
  # A table cell is the atomic unit of a table that contains content.
  # It can hold one or more paragraphs.
  #
  # Uses caching for efficient text extraction from large tables.
  class TableCell < Element
    extend LazyLoader

    # OOXML namespace configuration
    xml do
      element 'tc', mixed: true
      namespace Ooxml::Namespaces::WordProcessingML

      map_element 'tcPr', to: :cell_properties, prefix: 'w', namespace: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
      map_element 'p', to: :paragraphs, prefix: 'w', namespace: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
    end

    # Cell properties (formatting) - TableProperties object for span/width support
    attribute :cell_properties, Ooxml::WordProcessingML::TableProperties

    # Array of paragraphs in this cell
    attribute :paragraphs, Paragraph, collection: true, default: -> { [] }

    # Cell width (optional)
    attribute :width, :string

    # Cell background color
    attribute :background_color, :string

    # Vertical alignment (top, center, bottom)
    attribute :vertical_alignment, :string

    # Column span (for merged cells)
    attribute :colspan, :integer, default: -> { 1 }

    # Row span (for merged cells)
    attribute :rowspan, :integer, default: -> { 1 }

    # Alias for backward compatibility
    alias properties cell_properties
    alias properties= cell_properties=

    # Aliases for docx-js compatibility
    alias column_span colspan
    alias column_span= colspan=
    alias row_span rowspan
    alias row_span= rowspan=

    # Accept a visitor for the visitor pattern
    #
    # @param visitor [Object] The visitor object
    # @return [Object] The result of the visit operation
    def accept(visitor)
      visitor.visit_table_cell(self)
    end

    # Get the plain text content of this cell
    # Concatenates text from all paragraphs
    # Cached for performance with large tables
    #
    # @return [String] The combined text from all paragraphs
    def text
      @text ||= paragraphs.map(&:text).join("\n")
    end

    # Set the plain text content of this cell
    # Replaces all existing paragraphs with a single paragraph containing the text
    #
    # @param value [String] The text to set
    # @return [String] The text value
    def text=(value)
      paragraphs.clear
      add_text(value.to_s)
      clear_text_cache
      value
    end

    # Clear cached text (call when cell content changes)
    #
    # @return [void]
    def clear_text_cache
      @cached_text = nil
    end

    # Add a paragraph to this cell
    #
    # @param paragraph [Paragraph] The paragraph to add
    # @return [Array<Paragraph>] The updated paragraphs array
    def add_paragraph(paragraph)
      unless paragraph.is_a?(Paragraph)
        raise ArgumentError, 'paragraph must be a Paragraph instance'
      end

      clear_text_cache # Invalidate cache when content changes
      paragraphs << paragraph
    end

    # Create and add a paragraph with the given text
    #
    # @param text [String] The text content
    # @param properties [Ooxml::WordProcessingML::ParagraphProperties, nil] Optional properties
    # @return [TableCell] Returns self for method chaining
    def add_text(text, properties: nil)
      paragraph = Paragraph.new(properties: properties)
      paragraph.add_text(text)
      add_paragraph(paragraph)
      self
    end

    # Check if cell is empty (has no paragraphs or all paragraphs are empty)
    #
    # @return [Boolean] true if empty
    def empty?
      paragraphs.empty? || paragraphs.all?(&:empty?)
    end

    # Get the number of paragraphs in this cell
    #
    # @return [Integer] The number of paragraphs
    def paragraph_count
      paragraphs.size
    end
  end
end
