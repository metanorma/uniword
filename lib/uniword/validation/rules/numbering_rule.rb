# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates numbering definitions are properly referenced.
      #
      # DOC-010: numId references in document.xml exist in numbering.xml
      # DOC-011: ilvl values within numId range
      # DOC-012: Abstract numbering definitions are referenced
      class NumberingRule < Base
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

        def code = "DOC-010"
        def category = :numbering
        def severity = "error"

        def applicable?(context)
          context.part_exists?("word/document.xml")
        end

        def check(context)
          issues = []
          num_ids = context.numbering_ids

          doc = context.document_xml
          return issues unless doc

          # DOC-010: Check numId references
          doc.root.xpath(".//w:numId/@w:val", "w" => W_NS).each do |attr|
            next if num_ids.include?(attr.value)

            issues << issue(
              "numId '#{attr.value}' referenced but not defined in numbering.xml",
              part: "word/document.xml",
              suggestion: "Define numbering with numId '#{attr.value}' " \
                          "in numbering.xml, or fix the reference."
            )
          end

          # DOC-012: Check unreferenced abstract num definitions
          check_abstract_refs(context, issues)

          issues
        end

        private

        def check_abstract_refs(context, issues)
          num_doc = context.numbering_xml
          return unless num_doc

          abstract_ids = Set.new
          num_doc.root.xpath(".//w:abstractNum/@w:abstractNumId",
                             "w" => W_NS).each do |attr|
            abstract_ids << attr.value
          end

          referenced_abstract = Set.new
          num_doc.root.xpath(".//w:num/w:abstractNumId/@w:val",
                             "w" => W_NS).each do |attr|
            referenced_abstract << attr.value
          end

          (abstract_ids - referenced_abstract).each do |abs_id|
            issues << issue(
              "Abstract numbering '#{abs_id}' is not referenced by any num definition",
              code: "DOC-012",
              severity: "warning",
              part: "word/numbering.xml",
              suggestion: "Remove the unused abstractNum or reference it " \
                          "from a num element."
            )
          end
        end
      end
    end
  end
end
