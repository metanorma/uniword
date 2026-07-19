# frozen_string_literal: true

module Uniword
  module Validation
    module Rules
      # DOC-203: paragraphs should not be empty.
      #
      # Empty paragraphs are usually leftover scaffolding; reported as
      # warnings only.
      class EmptyParagraphsRule < ModelRule
        def code = "DOC-203"
        def category = :structure
        def severity = "warning"

        def check(context)
          paragraphs = context.document.paragraphs
          paragraphs.each_with_index.filter_map do |para, idx|
            next unless para.runs.nil? || para.runs.empty?

            issue("Empty paragraph at index #{idx}",
                  part: "word/document.xml")
          end
        end
      end
    end
  end
end
