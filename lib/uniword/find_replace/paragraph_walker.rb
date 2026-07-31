# frozen_string_literal: true

module Uniword
  module FindReplace
    # Walks an enumerable of containers (Body, TableCell, SDT, ...)
    # and yields every Paragraph reachable. Used by all scopes that
    # traverse paragraph-bearing parts (body, headers, footers,
    # footnotes, endnotes, comments).
    module ParagraphWalker
      module_function

      # @param containers [Enumerable<#paragraphs, #tables,
      #   #structured_document_tags>] containers to walk
      # @yieldparam paragraph [Wordprocessingml::Paragraph]
      # @return [void]
      def each_paragraph(containers, &block)
        containers.each do |container|
          walk_container(container, &block)
        end
      end

      # @param container [Object]
      # @yieldparam paragraph [Wordprocessingml::Paragraph]
      # @return [void]
      def walk_container(container, &block)
        container.paragraphs&.each(&block)
        walk_tables(container.tables, &block) if container.tables
        if container.structured_document_tags
          walk_sdts(container.structured_document_tags, &block)
        end
      end

      def walk_tables(tables, &block)
        tables.each do |table|
          walk_table_rows(table, &block) if table.rows
        end
      end

      def walk_table_rows(table, &block)
        table.rows.each do |row|
          walk_table_cells(row, &block) if row.cells
        end
      end

      def walk_table_cells(row, &block)
        row.cells.each do |cell|
          walk_container(cell, &block) if cell
        end
      end

      def walk_sdts(sdts, &block)
        sdts.each do |sdt|
          sdt.paragraphs&.each(&block)
        end
      end

      private_class_method :walk_container, :walk_tables, :walk_table_rows,
                           :walk_table_cells, :walk_sdts
    end
  end
end
