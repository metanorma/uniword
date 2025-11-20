# frozen_string_literal: true

require_relative 'table_row'
require_relative 'table_column'

module Uniword
  # Represents a table (block-level element)
  # Responsibility: Hold table structure (rows) and table-level formatting
  #
  # A table is a block-level element containing rows of cells.
  # It provides structured data presentation.
  class Table < Element
    # OOXML namespace configuration
    xml do
      root 'tbl', mixed: true
      namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

      map_element 'tblPr', to: :properties, prefix: 'w', namespace: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
      map_element 'tblGrid', to: :grid, prefix: 'w', namespace: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
      map_element 'tr', to: :rows, prefix: 'w', namespace: 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
    end

    # Table formatting properties
    attribute :properties, Properties::TableProperties, default: -> { Properties::TableProperties.new }

    # Table grid (column definitions)
    attribute :grid, :string

    # Array of rows in this table
    attribute :rows, TableRow, collection: true, default: -> { [] }

    # Table width (string or numeric value with units)
    attr_accessor :width

    # Table layout (auto or fixed)
    attr_accessor :layout

    # Float properties for table positioning
    attr_accessor :float_properties

    # Accept a visitor for the visitor pattern
    #
    # @param visitor [Object] The visitor object
    # @return [Object] The result of the visit operation
    def accept(visitor)
      visitor.visit_table(self)
    end

    # Add a row to this table
    # Supports both old API (TableRow instance) and new API (block-based)
    #
    # @param row [TableRow, nil] The row to add (optional)
    # @yield [TableRow] Optional block to configure the row
    # @return [TableRow] The added row
    def add_row(row = nil, &block)
      trow = row || TableRow.new

      unless trow.is_a?(TableRow)
        raise ArgumentError, 'row must be a TableRow instance'
      end

      # Yield to block if provided (for docx-js style API)
      yield(trow) if block_given?

      # Set parent table reference
      trow.parent_table = self
      rows << trow
      trow
    end

    # Create and add a row with cells containing the given texts
    #
    # @param cell_texts [Array<String>] Array of text for each cell
    # @param header [Boolean] Whether this is a header row
    # @return [TableRow] The created row
    def add_text_row(cell_texts, header: false)
      row = TableRow.new(header: header)
      cell_texts.each { |text| row.add_text_cell(text) }
      add_row(row)
      row
    end

    # Get the number of rows in this table
    #
    # @return [Integer] The number of rows
    def row_count
      rows.size
    end

    # Get the number of columns (based on first row)
    #
    # @return [Integer] The number of columns
    def column_count
      return 0 if rows.empty?

      rows.first.cell_count
    end

    # Check if table is empty (has no rows or all rows are empty)
    #
    # @return [Boolean] true if empty
    def empty?
      rows.empty? || rows.all?(&:empty?)
    end

    # Get header rows (rows marked as header)
    #
    # @return [Array<TableRow>] Array of header rows
    def header_rows
      rows.select(&:header?)
    end

    # Get data rows (non-header rows)
    #
    # @return [Array<TableRow>] Array of data rows
    def data_rows
      rows.reject(&:header?)
    end

    # Get columns (virtual construct for column-based iteration)
    # Compatible with docx gem API
    #
    # @return [Array<TableColumn>] Array of table columns
    def columns
      return [] if rows.empty?

      (0...column_count).map do |col_idx|
        column_cells = rows.map { |row| row.cells[col_idx] }.compact
        TableColumn.new(column_cells)
      end
    end
  end
end
