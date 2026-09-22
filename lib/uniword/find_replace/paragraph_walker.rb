# frozen_string_literal: true

module Uniword
  module FindReplace
    # Walks an enumerable of containers (Body, TableCell, Header,
    # Footer, Footnote, Endnote, Comment) and yields every Paragraph
    # reachable. Used by all scopes that traverse paragraph-bearing
    # parts (body, headers, footers, footnotes, endnotes, comments).
    #
    # Container classes map different subsets of OOXML block-level
    # content, so dispatch is explicit per class (mirrors
    # Docx::DocumentStatistics):
    # - Body maps paragraphs, tables, and structured document tags
    # - TableCell, Header, Footer map paragraphs and tables
    # - Footnote, Endnote, Comment map paragraphs only
    module ParagraphWalker
      module_function

      # @param containers [Enumerable<#paragraphs>] containers to walk
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
        case container
        when Wordprocessingml::Body
          walk_body(container, &block)
        else
          walk_non_body(container, &block)
        end
      end

      # Body is the only container class that maps structured
      # document tags.
      def walk_body(body, &block)
        body.paragraphs&.each(&block)
        walk_tables(body.tables, &block)
        walk_sdts(body.structured_document_tags, &block)
      end

      # TableCell, Header, and Footer map tables; Footnote, Endnote,
      # and Comment map paragraphs only.
      def walk_non_body(container, &block)
        container.paragraphs&.each(&block)
        return unless table_bearing?(container)

        walk_tables(container.tables, &block)
      end

      def table_bearing?(container)
        container.is_a?(Wordprocessingml::TableCell) ||
          container.is_a?(Wordprocessingml::Header) ||
          container.is_a?(Wordprocessingml::Footer)
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

      # SDT content (sdtContent) is itself a block-level container
      # with paragraphs, tables, and nested SDTs.
      def walk_sdts(sdts, &block)
        sdts.each do |sdt|
          next unless sdt.content

          sdt.content.paragraphs&.each(&block)
          walk_tables(sdt.content.tables, &block)
          walk_sdts(sdt.content.sdts, &block)
        end
      end

      private_class_method :walk_container, :walk_body, :walk_non_body,
                           :table_bearing?, :walk_tables, :walk_table_rows,
                           :walk_table_cells, :walk_sdts
    end
  end
end
