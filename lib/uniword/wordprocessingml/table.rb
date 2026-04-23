# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Table structure
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:tbl>
    class Table < Lutaml::Model::Serializable
      attribute :properties, TableProperties
      attribute :grid, TableGrid
      attribute :rows, TableRow, collection: true, initialize_empty: true
      attribute :alternate_content, AlternateContent, default: nil

      xml do
        element "tbl"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "tblPr", to: :properties, render_nil: false
        map_element "tblGrid", to: :grid, render_nil: false
        map_element "tr", to: :rows, render_nil: false
        map_element "AlternateContent", to: :alternate_content,
                                        render_nil: false
      end

      # Get row count
      #
      # @return [Integer] Number of rows in table
      def row_count
        rows.count
      end

      # Get column count
      #
      # @return [Integer] Maximum number of columns across all rows
      def column_count
        return 0 if rows.empty?

        rows.map { |r| r.cells&.count || 0 }.max || 0
      end

      # Check if table is empty (no rows)
      #
      # @return [Boolean] true if table has no rows
      def empty?
        rows.empty?
      end

      # Get columns (transposed view of table cells)
      #
      # @return [Array<Array<TableCell>>] Array of column arrays, each containing cells
      def columns
        return [] if rows.empty?

        max_cols = rows.map { |r| r.cells&.count || 0 }.max || 0
        (0...max_cols).map do |col_idx|
          rows.filter_map { |r| r.cells&.[](col_idx) }
        end
      end

      # Accept a visitor (Visitor pattern)
      #
      # @param visitor [BaseVisitor] The visitor to accept
      # @return [void]
      def accept(visitor)
        visitor.visit_table(self)
      end
    end
  end
end
