# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates that section properties exist with required children.
      #
      # DOC-104: sectPr exists with pgSz and pgMar
      # Validity rule: R11
      class SectionPropertiesRule < Base
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

        def code = "DOC-104"
        def validity_rule = "R11"
        def description = "Document body must have sectPr with pgSz and pgMar"
        def category = :structure
        def severity = "error"

        def applicable?(context)
          context.part_exists?("word/document.xml")
        end

        def check(context)
          issues = []
          doc = context.document_xml
          return issues unless doc

          body = doc.root.at_xpath("//w:body", "w" => W_NS)
          unless body
            issues << issue("Document missing w:body element",
                            part: "word/document.xml")
            return issues
          end

          sect_pr = body.at_xpath("w:sectPr", "w" => W_NS)
          unless sect_pr
            issues << issue(
              "Document body missing w:sectPr element",
              part: "word/document.xml",
              suggestion: "Add a w:sectPr with w:pgSz and w:pgMar " \
                          "to the end of w:body.",
            )
            return issues
          end

          pg_sz = sect_pr.at_xpath("w:pgSz", "w" => W_NS)
          unless pg_sz
            issues << issue(
              "Section properties missing w:pgSz",
              part: "word/document.xml",
              suggestion: "Add <w:pgSz w:w=\"12240\" w:h=\"15840\"/>.",
            )
          end

          pg_mar = sect_pr.at_xpath("w:pgMar", "w" => W_NS)
          unless pg_mar
            issues << issue(
              "Section properties missing w:pgMar",
              part: "word/document.xml",
              suggestion: "Add <w:pgMar w:top=\"1440\" w:right=\"1440\" " \
                          "w:bottom=\"1440\" w:left=\"1440\"/>.",
            )
          end

          issues
        end
      end
    end
  end
end
