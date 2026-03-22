# frozen_string_literal: true


module Uniword
  # Represents a table row
  # Responsibility: Hold a row of table cells and row-level formatting
  #
  # A table row contains one or more table cells arranged horizontally.
  class TableRow < Element
    # OOXML namespace configuration
    xml do
      element 'tr', mixed: true
      namespace Ooxml::Namespaces::WordProcessingML

      map_element 'trPr', to: :row_properties
      map_element 'tc', to: :cells
    end

    # Row properties
    attribute :row_properties, :string

    # Array of cells in this row
    attribute :cells, TableCell, collection: true, initialize_empty: true

    # Row height (optional)
    attribute :height, :string

    # Whether this is a header row
    attribute :header, :boolean, default: -> { false }

    # Allow row to break across pages
    attribute :allow_break, :boolean, default: -> { true }

    # Accept a visitor for the visitor pattern
    #
    # @param visitor [Object] The visitor object
    # @return [Object] The result of the visit operation
    def accept(visitor)
      visitor.visit_table_row(self)
    end

    # Add a cell to this row
    # Supports both old API (TableCell instance) and new API (string or block)
    #
    # @param cell_or_text [TableCell, String, nil] The cell to add or text content
    # @param kwargs [Hash] Optional cell properties (colspan, rowspan, etc.)
    # @yield [TableCell] Optional block to configure the cell
    # @return [TableCell] The added cell
    def add_cell(cell_or_text = nil, **kwargs)
      cell = case cell_or_text
             when TableCell
               # Old API: add_cell(cell_instance)
               cell_or_text
             when String
               # New API: add_cell("text", colspan: 2)
               c = create_cell_with_properties(kwargs)
               c.add_text(cell_or_text)
               c
             when nil
               # New API: add_cell(colspan: 2) { |c| c.add_text("text") }
               create_cell_with_properties(kwargs)
             else
               raise ArgumentError, 'cell must be a TableCell instance or String'
             end

      # Yield to block if provided (for docx-js style API)
      yield(cell) if block_given?

      cells << cell
      cell
    end

    # Create and add a cell with the given text
    #
    # @param text [String] The text content
    # @param properties [Hash] Optional cell properties
    # @return [TableCell] The created cell
    def add_text_cell(text, properties: {})
      cell = TableCell.new(properties)
      cell.add_text(text)
      add_cell(cell)
      cell
    end

    # Get the number of cells in this row
    #
    # @return [Integer] The number of cells
    def cell_count
      cells.size
    end

    # Check if row is empty (has no cells or all cells are empty)
    #
    # @return [Boolean] true if empty
    def empty?
      cells.empty? || cells.all?(&:empty?)
    end

    # Check if this is a header row
    #
    # @return [Boolean] true if header row
    def header?
      header
    end

    # Create a deep copy of this row
    # Compatible with docx gem API
    #
    # @return [TableRow] A new row with copied cells
    def copy
      new_row = TableRow.new(header: header?)
      cells.each do |cell|
        # Deep copy the cell
        new_cell = TableCell.new
        new_cell.properties = cell.properties.dup if cell.properties

        # Copy paragraphs from cell
        cell.paragraphs.each do |para|
          new_para = Paragraph.new
          para.runs.each do |run|
            new_run = Run.new(text: run.text)
            new_run.properties = run.properties.dup if run.properties
            new_para.add_run(new_run)
          end
          new_cell.add_paragraph(new_para)
        end

        new_row.add_cell(new_cell)
      end
      new_row
    end

    # Insert this row before another row in the table
    # Compatible with docx gem API
    #
    # @param other_row [TableRow] The row to insert before
    # @return [self] Returns self for method chaining
    def insert_before(other_row)
      return self unless other_row.parent_table

      parent_table = other_row.parent_table
      idx = parent_table.rows.index(other_row)
      return self unless idx

      parent_table.rows.insert(idx, self)
      self.parent_table = parent_table
      self
    end

    # Parent table accessor (set by table when added)
    attr_accessor :parent_table

    # Override equality to use object identity
    # This ensures that copied rows are not equal to their originals
    # Compatible with docx gem API expectations
    #
    # @param other [Object] The object to compare with
    # @return [Boolean] true if same object
    def ==(other)
      equal?(other)
    end

    alias eql? ==

    private

    # Create a new TableCell with properties applied
    #
    # @param properties [Hash] Cell properties (colspan, rowspan, etc.)
    # @return [TableCell] The created cell
    def create_cell_with_properties(properties)
      # Make a copy to avoid modifying the original hash
      props = properties.dup

      # Extract span properties
      colspan = props.delete(:colspan) || props.delete(:column_span)
      rowspan = props.delete(:rowspan) || props.delete(:row_span)

      # Extract other known TableCell properties
      width = props.delete(:width)
      background_color = props.delete(:background_color)
      vertical_alignment = props.delete(:vertical_alignment)

      # Create cell with known properties
      cell_attrs = {}
      cell_attrs[:width] = width if width
      cell_attrs[:background_color] = background_color if background_color
      cell_attrs[:vertical_alignment] = vertical_alignment if vertical_alignment

      cell = TableCell.new(**cell_attrs)

      # Set span properties if provided
      cell.colspan = colspan if colspan
      cell.rowspan = rowspan if rowspan

      cell
    end
  end
end
