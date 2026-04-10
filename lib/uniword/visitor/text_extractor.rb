# frozen_string_literal: true

module Uniword
  module Visitor
    # Concrete visitor that extracts all text content from a document.
    #
    # This visitor demonstrates the visitor pattern by traversing the document
    # structure and collecting text from all text-containing elements.
    #
    # @example Extract text from a document
    #   extractor = Uniword::Visitor::TextExtractor.new
    #   document.accept(extractor)
    #   text = extractor.text
    #
    # @example Extract text with separator
    #   extractor = Uniword::Visitor::TextExtractor.new(separator: "\n\n")
    #   document.accept(extractor)
    #   text = extractor.text
    class TextExtractor < BaseVisitor
      # Initialize a new text extractor.
      #
      # @param separator [String] the separator to use between text elements
      def initialize(separator: "\n")
        super()
        @separator = separator
        @text_parts = []
      end

      # @return [String] the extracted text joined by separator
      def text
        @text_parts.join(@separator)
      end

      # Visit a document and extract text from all its elements.
      #
      # @param document [Document] The document to visit
      # @return [void]
      def visit_document(document)
        # Visit both paragraphs and tables from body
        if document.body.respond_to?(:elements)
          document.body.elements.each do |element|
            element.accept(self) if element.respond_to?(:accept)
          end
        else
          # Legacy support: visit paragraphs only
          document.elements.each do |element|
            element.accept(self) if element.respond_to?(:accept)
          end
        end
      end

      # Visit a paragraph and extract its text content.
      #
      # @param paragraph [Paragraph] The paragraph to visit
      # @return [void]
      def visit_paragraph(paragraph)
        paragraph_text = paragraph.runs.map do |run|
          run.accept(self)
          @text_parts.pop # Get the last added text
        end.compact.join

        @text_parts << paragraph_text unless paragraph_text.empty?
      end

      # Visit a table and extract text from all its cells.
      #
      # @param table [Table] The table to visit
      # @return [void]
      def visit_table(table)
        table.rows.each do |row|
          row.accept(self)
        end
      end

      # Visit a table row and extract text from all its cells.
      #
      # @param table_row [TableRow] The table row to visit
      # @return [void]
      def visit_table_row(table_row)
        row_text = table_row.cells.map do |cell|
          cell.accept(self)
          @text_parts.pop # Get the last added text
        end.compact.join(' | ')

        @text_parts << row_text unless row_text.empty?
      end

      # Visit a table cell and extract its text content.
      #
      # @param table_cell [TableCell] The table cell to visit
      # @return [void]
      def visit_table_cell(table_cell)
        cell_text = table_cell.paragraphs.map do |paragraph|
          paragraph.accept(self)
          @text_parts.pop # Get the last added text
        end.compact.join

        @text_parts << cell_text
      end

      # Visit a run and extract its text content.
      #
      # @param run [Run] The run to visit
      # @return [void]
      def visit_run(run)
        @text_parts << run.text if run.text
      end

      # Visit an image element.
      # Images don't contain text, so this is a no-op.
      #
      # @param image [Image] The image to visit
      # @return [void]
      def visit_image(image)
        # Images don't contain text, intentionally empty
      end
    end
  end
end
