# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Document body - main content container
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:body>
    class Body < Lutaml::Model::Serializable
      attribute :paragraphs, Paragraph, collection: true, default: -> { [] }
      attribute :tables, Table, collection: true, default: -> { [] }
      attribute :section_properties, SectionProperties

      xml do
        element 'body'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'p', to: :paragraphs, render_nil: false
        map_element 'tbl', to: :tables, render_nil: false
        map_element 'sectPr', to: :section_properties, render_nil: false
      end

      # Add paragraph to body
      #
      # @param paragraph_or_text [Paragraph, String, nil] Paragraph object or text
      # @param options [Hash] Options for creating paragraph with text
      # @return [Paragraph] The added paragraph
      def add_paragraph(paragraph_or_text = nil, **options)
        case paragraph_or_text
        when Paragraph
          paragraphs << paragraph_or_text
          paragraph_or_text
        when String
          para = Paragraph.new
          para.add_text(paragraph_or_text, **options)
          paragraphs << para
          para
        else
          para = Paragraph.new(**options)
          paragraphs << para
          para
        end
      end

      # Add table to body
      #
      # @param rows_or_table [Integer, Table, nil] Number of rows or pre-built Table object
      # @param cols [Integer, nil] Number of columns
      # @return [Table] The created or added table
      def add_table(rows_or_table = nil, cols = nil)
        # Handle case where first arg is a Table object
        if rows_or_table.is_a?(Table)
          table = rows_or_table
          tables << table
          return table
        end

        rows = rows_or_table
        table = Table.new

        # Create rows and cells if dimensions provided
        if rows && cols
          rows.times do
            row = TableRow.new
            row.cells = []

            cols.times do
              cell = TableCell.new
              cell.paragraphs = [Paragraph.new]
              row.cells << cell
            end

            table.rows << row
          end
        end

        tables << table
        table
      end

      # Get all elements in body (paragraphs, tables, section properties)
      #
      # @return [Array<Paragraph, Table, SectionProperties>] All block-level content
      def elements
        result = []
        result.concat(paragraphs || [])
        result.concat(tables || [])
        result << section_properties if section_properties
        result
      end
    end
  end
end
