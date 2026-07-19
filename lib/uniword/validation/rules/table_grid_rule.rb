# frozen_string_literal: true

module Uniword
  module Validation
    module Rules
      # DOC-204: every table must have a tblGrid.
      #
      # wml.xsd CT_Tbl requires exactly one tblGrid child; without it
      # Word cannot lay out column widths and repairs the document.
      class TableGridRule < ModelRule
        def code = "DOC-204"
        def category = :tables
        def severity = "error"

        def check(context)
          context.document.tables.each_with_index.filter_map do |table, idx|
            next if table.grid

            issue("Table #{idx + 1} is missing the required tblGrid element",
                  part: "word/document.xml",
                  suggestion: "Add a w:tblGrid with one w:gridCol per column.")
          end
        end
      end
    end
  end
end
