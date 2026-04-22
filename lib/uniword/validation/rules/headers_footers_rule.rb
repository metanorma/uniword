# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates header and footer references.
      #
      # DOC-030: headerReference/footerReference targets exist in ZIP
      # DOC-031: headerReference/footerReference type is valid
      class HeadersFootersRule < Base
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
        R_NS = "http://schemas.openxmlformats.org/officeDocument/2006/relationships"

        VALID_TYPES = %w[default first even].freeze

        def code = "DOC-030"
        def category = :headers_footers
        def severity = "error"

        def applicable?(context)
          context.part_exists?("word/document.xml")
        end

        def check(context)
          issues = []
          doc = context.document_xml
          return issues unless doc

          rels = context.relationships
          rels_by_id = rels.each_with_object({}) { |r, h| h[r[:id]] = r }

          # Check header references
          doc.root.xpath(".//w:headerReference", "w" => W_NS).each do |ref|
            check_reference(ref, "header", rels_by_id, context, issues)
          end

          # Check footer references
          doc.root.xpath(".//w:footerReference", "w" => W_NS).each do |ref|
            check_reference(ref, "footer", rels_by_id, context, issues)
          end

          issues
        end

        private

        def check_reference(ref, kind, rels_by_id, context, issues)
          rid = ref["#{R_NS[%r{/([^/]+)$}]}:id"] ||
                ref.attributes.find { |a| a.name == "id" }&.value
          return unless rid

          rel = rels_by_id[rid]
          unless rel
            issues << issue(
              "#{kind} reference r:id='#{rid}' not found in relationships",
              part: "word/document.xml",
              suggestion: "Add a relationship for r:id='#{rid}' in " \
                          "word/_rels/document.xml.rels."
            )
            return
          end

          target = rel[:target]
          target_path = target.start_with?("/") ? target[1..] : "word/#{target}"

          unless context.part_exists?(target_path)
            issues << issue(
              "#{kind.capitalize} target '#{target_path}' not found in package",
              part: "word/document.xml",
              suggestion: "Create '#{target_path}' or fix the relationship target."
            )
          end

          # DOC-031: Check type
          type_attr = ref.attributes.find { |a| a.name == "type" }
          return unless type_attr && !VALID_TYPES.include?(type_attr.value)

          issues << issue(
            "#{kind.capitalize} reference has invalid type '#{type_attr.value}'",
            code: "DOC-031",
            severity: "warning",
            part: "word/document.xml",
            suggestion: "Valid types are: #{VALID_TYPES.join(", ")}."
          )
        end
      end
    end
  end
end
