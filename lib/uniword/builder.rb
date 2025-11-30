# frozen_string_literal: true

require_relative 'document'
require_relative 'paragraph'
require_relative 'table'

module Uniword
  # Document builder with fluent interface and DSL support
  # Provides an easy, chainable API for document construction
  #
  # @example Build a document with method chaining
  #   doc = Uniword::Builder.new
  #     .add_paragraph("Title", style: 'Heading1')
  #     .add_paragraph("Bold text", bold: true)
  #     .build
  #
  # @example Build a document with DSL block
  #   doc = Uniword::Builder.new do |d|
  #     d.add_heading("My Document", level: 1)
  #     d.add_paragraph("Introduction text")
  #     d.add_table do
  #       row do
  #         cell "Header 1", bold: true
  #         cell "Header 2", bold: true
  #       end
  #       row do
  #         cell "Data 1"
  #         cell "Data 2"
  #       end
  #     end
  #   end
  #   doc.save("output.docx")
  class Builder
    # @return [Document] The document being built
    attr_reader :document

    # Initialize a new builder with optional DSL block
    #
    # @param document [Document, nil] Optional existing document to build upon
    # @yield [self] Yields the builder for DSL-style document construction
    #
    # @example With DSL block
    #   builder = Uniword::Builder.new do |b|
    #     b.add_paragraph("Hello World")
    #   end
    #
    # @example Without block
    #   builder = Uniword::Builder.new
    #   builder.add_paragraph("Hello World")
    def initialize(document = nil)
      @document = document || Document.new
      yield(self) if block_given?
    end

    # Add a paragraph to the document
    #
    # @param text [String, nil] Optional text content
    # @param style [String, nil] Optional paragraph style
    # @param alignment [String, nil] Optional alignment (left, right, center, justify)
    # @param bold [Boolean] Make text bold
    # @param italic [Boolean] Make text italic
    # @param underline [String] Underline style
    # @param font [String] Font name
    # @param size [Integer] Font size in half-points
    # @param color [String] Text color
    # @return [self] Returns self for method chaining
    def add_paragraph(text = nil, style: nil, alignment: nil, **run_options)
      para = Paragraph.new
      para.set_style(style) if style
      para.align(alignment) if alignment
      para.add_text(text, **run_options) if text
      @document.add_element(para)
      self
    end

    # Add a table to the document with a builder block
    #
    # @yield [TableBuilder] Yields a table builder for configuring the table
    # @return [self] Returns self for method chaining
    #
    # @example
    #   builder.add_table do
    #     row do
    #       cell "A1"
    #       cell "B1"
    #     end
    #     row do
    #       cell "A2"
    #       cell "B2"
    #     end
    #   end
    def add_table(&block)
      table = Table.new
      table_builder = TableBuilder.new(table)
      table_builder.instance_eval(&block) if block
      @document.add_element(table)
      self
    end

    # Add a heading paragraph
    #
    # @param text [String] The heading text
    # @param level [Integer] Heading level (1-9)
    # @param alignment [String, nil] Optional alignment
    # @return [self] Returns self for method chaining
    def add_heading(text, level: 1, alignment: nil)
      style = "Heading#{level}"
      add_paragraph(text, style: style, alignment: alignment)
    end

    # Add a blank paragraph
    #
    # @return [self] Returns self for method chaining
    def add_blank_line
      para = Paragraph.new
      para.add_text('')
      @document.add_element(para)
      self
    end

    # Build and return the document
    #
    # @return [Document] The constructed document
    def build
      @document
    end

    # Alias for add_paragraph for more natural DSL
    alias paragraph add_paragraph

    # Alias for add_table for more natural DSL
    alias table add_table

    # Alias for add_heading for more natural DSL
    alias heading add_heading

    # Alias for add_blank_line for more natural DSL
    alias blank_line add_blank_line

    # Get the built document
    # This is an alias for build for more natural usage
    #
    # @return [Document] The constructed document
    def to_doc
      @document
    end
  end

  # Table builder for fluent table construction
  class TableBuilder
    # @return [Table] The table being built
    attr_reader :table

    # Initialize a table builder
    #
    # @param table [Table] The table to build
    def initialize(table)
      @table = table
      @current_row = nil
    end

    # Add a row to the table with a builder block
    #
    # @yield [RowBuilder] Yields a row builder for configuring the row
    # @return [self] Returns self for method chaining
    def row(&block)
      @current_row = TableRow.new
      row_builder = RowBuilder.new(@current_row)
      row_builder.instance_eval(&block) if block
      @table.add_row(@current_row)
      self
    end
  end

  # Row builder for fluent row construction
  class RowBuilder
    # @return [TableRow] The row being built
    attr_reader :row

    # Initialize a row builder
    #
    # @param row [TableRow] The row to build
    def initialize(row)
      @row = row
    end

    # Add a cell to the row
    #
    # @param text [String, nil] Optional cell text
    # @param bold [Boolean] Make text bold
    # @param italic [Boolean] Make text italic
    # @param alignment [String, nil] Cell alignment
    # @return [self] Returns self for method chaining
    def cell(text = nil, bold: false, italic: false, alignment: nil)
      cell_obj = TableCell.new

      if text
        para = Paragraph.new
        para.add_text(text, bold: bold, italic: italic)
        para.align(alignment) if alignment
        cell_obj.add_paragraph(para)
      end

      @row.add_cell(cell_obj)
      self
    end
  end
end
