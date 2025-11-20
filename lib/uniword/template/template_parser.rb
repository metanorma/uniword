# frozen_string_literal: true

require_relative 'template_marker'

module Uniword
  module Template
    # Parses template syntax from Word document comments.
    #
    # Extracts template markers (variables, loops, conditionals) from
    # comments attached to document elements. Converts Uniword template
    # syntax into structured marker objects.
    #
    # Responsibility: Marker extraction only
    # Single Responsibility Principle: Does NOT render or validate
    #
    # Template Syntax:
    # - {{variable}} - Variable substitution
    # - {{object.property}} - Nested property access
    # - {{@each collection}} - Loop start
    # - {{@end}} - Loop/conditional end
    # - {{@if condition}} - Conditional start
    # - {{@unless condition}} - Negative conditional
    #
    # @example Parse simple template
    #   parser = TemplateParser.new(document)
    #   markers = parser.parse
    #   # Returns array of TemplateMarker objects
    class TemplateParser
      # Initialize parser with document
      #
      # @param document [Document] Document to parse
      def initialize(document)
        @document = document
        @markers = []
      end

      # Parse all markers from document
      #
      # Iterates through paragraphs and tables, extracting markers
      # from comments. Returns markers sorted by document position.
      #
      # @return [Array<TemplateMarker>] Sorted array of markers
      def parse
        @markers = []

        # Parse paragraphs
        parse_paragraphs(@document.paragraphs)

        # Parse tables
        parse_tables(@document.tables) if @document.tables.any?

        # Sort markers by document order
        @markers.sort_by(&:position)
      end

      private

      # Parse markers from paragraphs
      #
      # @param paragraphs [Array<Paragraph>] Paragraphs to parse
      # @return [void]
      def parse_paragraphs(paragraphs)
        paragraphs.each_with_index do |para, index|
          # Check paragraph's own comments
          if para.respond_to?(:comments) && para.comments
            para.comments.each do |comment|
              marker = parse_comment_text(comment.text, para, index)
              @markers << marker if marker
            end
          end

          # Check run comments
          if para.respond_to?(:runs)
            para.runs.each do |run|
              if run.respond_to?(:comments) && run.comments
                run.comments.each do |comment|
                  marker = parse_comment_text(comment.text, run, index)
                  @markers << marker if marker
                end
              end
            end
          end
        end
      end

      # Parse markers from tables
      #
      # @param tables [Array<Table>] Tables to parse
      # @return [void]
      def parse_tables(tables)
        tables.each_with_index do |table, table_index|
          # Calculate base position for table
          base_position = @document.paragraphs.size + table_index * 100

          # Parse table rows
          if table.respond_to?(:rows)
            table.rows.each_with_index do |row, row_index|
              row_position = base_position + row_index * 10

              # Check row comments
              if row.respond_to?(:comments) && row.comments
                row.comments.each do |comment|
                  marker = parse_comment_text(comment.text, row, row_position)
                  @markers << marker if marker
                end
              end

              # Parse cells
              if row.respond_to?(:cells)
                row.cells.each_with_index do |cell, cell_index|
                  cell_position = row_position + cell_index

                  # Parse cell paragraphs
                  if cell.respond_to?(:paragraphs)
                    parse_paragraphs(cell.paragraphs)
                  end
                end
              end
            end
          end
        end
      end

      # Parse comment text to extract marker
      #
      # @param text [String] Comment text
      # @param element [Element] Document element
      # @param position [Integer] Document position
      # @return [TemplateMarker, nil] Marker or nil if not valid syntax
      def parse_comment_text(text, element, position)
        return nil unless text

        # Remove whitespace
        clean_text = text.strip

        # Parse different marker types
        case clean_text
        when /^\{\{@each\s+(\w+(\.\w+)*)\}\}$/
          # Loop start: {{@each collection}}
          TemplateMarker.new(
            type: :loop_start,
            collection: ::Regexp.last_match(1),
            element: element,
            position: position
          )

        when /^\{\{@end\}\}$/
          # Loop/conditional end: {{@end}}
          TemplateMarker.new(
            type: :loop_end,
            element: element,
            position: position
          )

        when /^\{\{@if\s+(.+)\}\}$/
          # Conditional: {{@if condition}}
          TemplateMarker.new(
            type: :conditional_start,
            condition: ::Regexp.last_match(1),
            element: element,
            position: position
          )

        when /^\{\{@unless\s+(.+)\}\}$/
          # Negative conditional: {{@unless condition}}
          # Convert to @if with negation
          TemplateMarker.new(
            type: :conditional_start,
            condition: "!(#{::Regexp.last_match(1)})",
            element: element,
            position: position
          )

        when /^\{\{([^@].+?)\}\}$/
          # Variable: {{variable}} or {{object.property}}
          TemplateMarker.new(
            type: :variable,
            expression: ::Regexp.last_match(1).strip,
            element: element,
            position: position
          )

        else
          # Not a valid template marker
          nil
        end
      end
    end
  end
end