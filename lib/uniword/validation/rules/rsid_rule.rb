# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates that paragraphs have rsid attributes.
      #
      # DOC-109: Paragraphs should have w:rsidR and w:rsidRDefault
      # Validity rule: R12
      class RsidRule < Base
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

        def code = "DOC-109"
        def validity_rule = "R12"
        def description = "Paragraphs should have rsidR and rsidRDefault attributes"
        def category = :structure
        def severity = "warning"

        def applicable?(context)
          context.part_exists?("word/document.xml")
        end

        def check(context)
          issues = []
          doc = context.document_xml
          return issues unless doc

          paras = doc.root.xpath("//w:body/w:p", "w" => W_NS)
          return issues if paras.empty?

          missing_rsid_r = 0
          missing_rsid_r_default = 0

          paras.each do |para|
            missing_rsid_r += 1 unless para["w:rsidR"]
            missing_rsid_r_default += 1 unless para["w:rsidRDefault"]
          end

          total = paras.size
          if missing_rsid_r == total
            issues << issue(
              "No paragraphs have w:rsidR attribute (#{total} paragraphs)",
              part: "word/document.xml",
              severity: "warning",
              suggestion: "Add rsidR attributes to paragraphs for change tracking.",
            )
          end

          if missing_rsid_r_default == total
            issues << issue(
              "No paragraphs have w:rsidRDefault attribute (#{total} paragraphs)",
              part: "word/document.xml",
              severity: "warning",
              suggestion: "Add rsidRDefault attributes to paragraphs.",
            )
          end

          issues
        end
      end
    end
  end
end
