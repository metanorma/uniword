# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates table structure.
      #
      # DOC-060: Table grid columns match cell tc count
      # DOC-061: Merge cells have valid gridSpan/vMerge
      class TablesRule < Base
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

        def code = "DOC-060"
        def category = :tables
        def severity = "warning"

        def applicable?(context)
          context.part_exists?("word/document.xml")
        end

        def check(context)
          issues = []
          doc = context.document_xml
          return issues unless doc

          doc.root.xpath(".//w:tbl", "w" => W_NS).each_with_index do |table, idx|
            check_table(table, idx, issues)
          end

          issues
        end

        private

        def check_table(table, idx, issues)
          # Get grid columns
          grid = table.at_xpath(".//w:tblGrid", "w" => W_NS)
          grid_cols = grid&.xpath(".//w:gridCol", "w" => W_NS)&.count || 0

          return if grid_cols.zero?

          # Check each row
          table.xpath(".//w:tr", "w" => W_NS).each_with_index do |row, row_idx|
            cells = row.xpath(".//w:tc", "w" => W_NS)
            cell_span = cells.sum do |tc|
              span = tc.at_xpath(".//w:gridSpan/@w:val", "w" => W_NS)
              span ? span.value.to_i : 1
            end

            next if cell_span == grid_cols

            issues << issue(
              "Table #{idx + 1} row #{row_idx + 1}: expected #{grid_cols} " \
              "columns, found #{cell_span}",
              code: "DOC-060",
              severity: "warning",
              part: "word/document.xml",
              suggestion: "Adjust gridSpan values or add/remove cells " \
                          "to match the grid."
            )
          end
        end
      end
    end
  end
end
