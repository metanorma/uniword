# frozen_string_literal: true

module Uniword
  module Validation
    module Rules
      # DOC-200: the document must have a body.
      #
      # A w:document without w:body carries no content; every document
      # must contain exactly one body element.
      class DocumentBodyRule < ModelRule
        def code = "DOC-200"
        def category = :structure
        def severity = "error"

        def check(context)
          return [] if context.document.body

          [issue("Document body is missing",
                 part: "word/document.xml",
                 suggestion: "Add a w:body element to the document.")]
        end
      end
    end
  end
end
