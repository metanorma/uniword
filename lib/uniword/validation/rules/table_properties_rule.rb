# frozen_string_literal: true

module Uniword
  module Validation
    module Rules
      # DOC-205: every table must have table properties (tblPr).
      #
      # wml.xsd CT_Tbl requires exactly one tblPr child as the table's
      # first property element.
      class TablePropertiesRule < ModelRule
        def code = "DOC-205"
        def category = :tables
        def severity = "error"

        def check(context)
          context.document.tables.each_with_index.filter_map do |table, idx|
            next if table.properties

            issue("Table #{idx + 1} is missing the required tblPr element",
                  part: "word/document.xml",
                  suggestion: "Add a w:tblPr element to the table.")
          end
        end
      end
    end
  end
end
