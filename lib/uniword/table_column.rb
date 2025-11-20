# frozen_string_literal: true

module Uniword
  # Represents a column in a table (virtual construct for convenience)
  # This is a convenience class for column-based iteration
  # Compatible with docx gem API
  class TableColumn
    attr_reader :cells

    # Initialize with array of cells
    #
    # @param cells [Array<TableCell>] Cells in this column
    def initialize(cells)
      @cells = cells
    end

    # Iterate over cells in this column
    #
    # @yield [TableCell] Gives each cell to the block
    # @return [void]
    def each(&block)
      cells.each(&block)
    end

    # Get number of cells in column
    #
    # @return [Integer] Number of cells
    def count
      cells.count
    end

    alias size count
  end
end