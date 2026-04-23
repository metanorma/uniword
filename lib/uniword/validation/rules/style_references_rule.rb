# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates style references exist in styles.xml.
      #
      # DOC-001: Style IDs referenced in document.xml exist in styles.xml
      # DOC-002: Default paragraph style exists
      # DOC-003: Style references in numbering.xml exist in styles.xml
      class StyleReferencesRule < Base
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

        def code = "DOC-001"
        def category = :styles
        def severity = "error"

        def applicable?(context)
          context.part_exists?("word/document.xml") &&
            context.part_exists?("word/styles.xml")
        end

        def check(context)
          issues = []
          defined_ids = context.style_ids
          check_document_refs(context, defined_ids, issues)
          check_default_style(context, defined_ids, issues)
          check_numbering_refs(context, defined_ids, issues)
          issues
        end

        private

        def check_document_refs(context, defined_ids, issues)
          doc = context.document_xml
          return unless doc

          referenced = Set.new
          doc.root.xpath(".//w:pStyle/@w:val", "w" => W_NS).each do |attr|
            referenced << attr.value
          end
          doc.root.xpath(".//w:rStyle/@w:val", "w" => W_NS).each do |attr|
            referenced << attr.value
          end
          doc.root.xpath(".//w:tblStyle/@w:val", "w" => W_NS).each do |attr|
            referenced << attr.value
          end

          (referenced - defined_ids).each do |style_id|
            issues << issue(
              "Style '#{style_id}' referenced in document.xml but not defined in styles.xml",
              part: "word/document.xml",
              suggestion: "Define style '#{style_id}' in styles.xml, " \
                          "or remove references to it.",
            )
          end
        end

        def check_default_style(context, _defined_ids, issues)
          doc = context.styles_xml
          return unless doc

          has_default = doc.root.xpath(".//w:style[@w:default='1']",
                                       "w" => W_NS).any?
          return if has_default

          issues << issue(
            "No default style defined in styles.xml",
            code: "DOC-002",
            severity: "warning",
            part: "word/styles.xml",
            suggestion: "Set w:default='1' on a paragraph style to define " \
                        "the document default.",
          )
        end

        def check_numbering_refs(context, defined_ids, issues)
          doc = context.numbering_xml
          return unless doc

          doc.root.xpath(".//w:pStyle/@w:val", "w" => W_NS).each do |attr|
            next if defined_ids.include?(attr.value)

            issues << issue(
              "Style '#{attr.value}' referenced in numbering.xml but not defined",
              code: "DOC-003",
              severity: "warning",
              part: "word/numbering.xml",
              suggestion: "Define style '#{attr.value}' in styles.xml.",
            )
          end
        end
      end
    end
  end
end
