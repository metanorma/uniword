# frozen_string_literal: true

module Uniword
  module Visitor
    # Abstract base class defining visitor interface for traversing document elements.
    #
    # The Visitor pattern allows you to separate algorithms from the object structure
    # they operate on, enabling new operations to be added without modifying the
    # element classes.
    #
    # @example Creating a custom visitor
    #   class MyVisitor < Uniword::Visitor::BaseVisitor
    #     def visit_paragraph(paragraph)
    #       # Custom paragraph processing
    #     end
    #
    #     def visit_run(run)
    #       # Custom run processing
    #     end
    #   end
    #
    # @abstract Subclass and override visit methods to implement custom behavior
    class BaseVisitor
      # Visit a document element.
      #
      # @param document [Document] The document to visit
      # @return [void]
      def visit_document(document)
        # Default no-op implementation
      end

      # Visit a paragraph element.
      #
      # @param paragraph [Paragraph] The paragraph to visit
      # @return [void]
      def visit_paragraph(paragraph)
        # Default no-op implementation
      end

      # Visit a table element.
      #
      # @param table [Table] The table to visit
      # @return [void]
      def visit_table(table)
        # Default no-op implementation
      end

      # Visit a table row element.
      #
      # @param table_row [TableRow] The table row to visit
      # @return [void]
      def visit_table_row(table_row)
        # Default no-op implementation
      end

      # Visit a table cell element.
      #
      # @param table_cell [TableCell] The table cell to visit
      # @return [void]
      def visit_table_cell(table_cell)
        # Default no-op implementation
      end

      # Visit a run element.
      #
      # @param run [Run] The run to visit
      # @return [void]
      def visit_run(run)
        # Default no-op implementation
      end

      # Visit an image element.
      #
      # @param image [Image] The image to visit
      # @return [void]
      def visit_image(image)
        # Default no-op implementation
      end
    end
  end
end
