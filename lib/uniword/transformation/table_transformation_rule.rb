# frozen_string_literal: true

module Uniword
  module Transformation
    # Transformation rule for Table elements.
    #
    # Responsibility: Transform Table objects between DOCX and MHTML formats.
    # Single Responsibility - handles only Table transformations.
    #
    # Transforms table structure including rows, cells, and all properties.
    #
    # @example Transform DOCX table to MHTML
    #   rule = TableTransformationRule.new(source_format: :docx, target_format: :mhtml)
    #   mhtml_table = rule.transform(docx_table)
    class TableTransformationRule < TransformationRule
      # Check if this rule matches the transformation request
      #
      # @param element_type [Class] The element class
      # @param source_format [Symbol] Source format
      # @param target_format [Symbol] Target format
      # @return [Boolean] true if matches
      def matches?(element_type:, source_format:, target_format:)
        element_type == Table &&
          source_format == @source_format &&
          target_format == @target_format
      end

      # Transform a table from source format to target format
      #
      # Creates new Table with all rows and cells transformed.
      #
      # @param source_table [Table] Source table
      # @return [Table] Transformed table
      # @raise [ArgumentError] if source_table is not a Table
      def transform(source_table)
        validate_element_type(source_table, Table)

        target_table = Table.new

        # Transform table-level properties
        transform_properties(source_table, target_table)

        # Transform each row
        source_table.rows.each do |source_row|
          target_row = transform_row(source_row)
          target_table.rows << target_row
        end

        target_table
      end

      private

      # Transform table properties
      #
      # @param source [Table] Source table
      # @param target [Table] Target table
      def transform_properties(source, target)
        return unless source.properties

        target.properties = Properties::TableProperties.new(
          width: source.properties.width,
          width_type: source.properties.width_type,
          alignment: source.properties.alignment,
          border_style: source.properties.border_style,
          borders: source.properties.borders,
        )
      end

      # Transform a table row
      #
      # @param source_row [TableRow] Source row
      # @return [TableRow] Transformed row
      def transform_row(source_row)
        target_row = TableRow.new
        target_row.header = source_row.header
        target_row.height = source_row.height

        # Transform each cell
        source_row.cells.each do |source_cell|
          target_cell = transform_cell(source_cell)
          target_row.cells << target_cell
        end

        target_row
      end

      # Transform a table cell
      #
      # @param source_cell [TableCell] Source cell
      # @return [TableCell] Transformed cell
      def transform_cell(source_cell)
        target_cell = TableCell.new

        # Copy cell properties
        target_cell.properties = TableCellProperties.new if source_cell.properties
        if target_cell.properties
          target_cell.properties.width = source_cell.properties&.width
          target_cell.properties.grid_span = source_cell.properties&.grid_span
          target_cell.properties.vertical_merge = source_cell.properties&.vertical_merge
          target_cell.properties.shading = source_cell.properties&.shading
          target_cell.properties.vertical_align = source_cell.properties&.vertical_align
        end

        # Transform cell content (paragraphs)
        para_rule = ParagraphTransformationRule.new(
          source_format: @source_format,
          target_format: @target_format,
        )

        source_cell.paragraphs.each do |source_para|
          target_para = para_rule.transform(source_para)
          target_cell.paragraphs << target_para
        end

        target_cell
      end
    end
  end
end
