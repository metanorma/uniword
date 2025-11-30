# frozen_string_literal: true

module Uniword
  module Styles
    module DSL
      # Table Context - DSL for table building
      #
      # Responsibility: Provide DSL methods for building tables
      # Single Responsibility: Table row and cell creation only
      #
      # This context is used within the StyleBuilder#table method to provide
      # a fluent interface for adding rows and cells with proper formatting.
      #
      # @example
      #   table do
      #     row header: true do
      #       cell "Column 1"
      #       cell "Column 2"
      #     end
      #     row do
      #       cell "Data 1"
      #       cell "Data 2"
      #     end
      #   end
      class TableContext
        # Initialize table context
        #
        # @param table [Table] The table to build
        # @param library [StyleLibrary] The style library for cell styling
        def initialize(table, library)
          @table = table
          @library = library
          @current_row = nil
        end

        # Add table row
        #
        # @param header [Boolean] Whether this is a header row
        # @yield [self] Block to define cells in the row
        # @return [TableRow] The created row
        #
        # @example
        #   row header: true do
        #     cell "Header 1"
        #     cell "Header 2"
        #   end
        def row(header: false, &block)
          @current_row = TableRow.new(header: header)

          instance_eval(&block) if block_given?

          @table.add_row(@current_row)
          @current_row
        end

        # Add table cell to current row
        #
        # @param text [String] Cell text content
        # @param style [String, Symbol, nil] Optional paragraph style for cell content
        # @param colspan [Integer] Column span (default: 1)
        # @param rowspan [Integer] Row span (default: 1)
        # @return [TableCell] The created cell
        #
        # @example
        #   cell "Simple text"
        #   cell "Styled text", style: :body_text
        #   cell "Merged cell", colspan: 2
        def cell(text, style: nil, colspan: 1, rowspan: 1)
          raise "No active row. Use 'row' first." unless @current_row

          cell = TableCell.new
          cell.colspan = colspan if colspan > 1
          cell.rowspan = rowspan if rowspan > 1

          # Add text as paragraph
          para = Paragraph.new
          para.add_text(text)

          # Apply style if specified
          if style
            style_def = @library.paragraph_style(style)
            apply_paragraph_style(para, style_def)
          end

          cell.add_paragraph(para)
          @current_row.add_cell(cell)
          cell
        end

        private

        # Apply paragraph style definition to paragraph
        #
        # @param para [Paragraph] The paragraph to style
        # @param style_def [ParagraphStyleDefinition] The style definition
        # @return [void]
        def apply_paragraph_style(para, style_def)
          # Resolve inherited properties
          resolved = style_def.resolve_inheritance(@library)

          # Apply paragraph properties
          if resolved[:properties]&.any?
            para.properties = Ooxml::WordProcessingML::ParagraphProperties.new(
              **resolved[:properties]
            )
          end

          # Store default run properties
          return unless resolved[:run_properties]&.any?

          para.instance_variable_set(:@default_run_properties, resolved[:run_properties])
        end
      end
    end
  end
end
