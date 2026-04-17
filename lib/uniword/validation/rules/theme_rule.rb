# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates theme references.
      #
      # DOC-080: Theme relationship exists if theme colors/fonts referenced
      # DOC-081: Theme part is well-formed DrawingML
      class ThemeRule < Base
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
        A_NS = "http://schemas.openxmlformats.org/drawingml/2006/main"

        def code = "DOC-080"
        def category = :theme
        def severity = "warning"

        def applicable?(context)
          context.part_exists?("word/document.xml")
        end

        def check(context)
          issues = []
          doc = context.document_xml
          return issues unless doc

          # Check if theme attributes are used
          uses_theme = doc.root.xpath(".//@w:val",
                                      "w" => W_NS).any? do |attr|
            attr.value&.start_with?("theme")
          end

          has_theme_rels = context.relationships.any? do |r|
            r[:type]&.include?("theme")
          end

          # DOC-080: Theme referenced but not available
          if uses_theme && !has_theme_rels && !context.part_exists?("word/theme/theme1.xml")
            issues << issue(
              "Document uses theme colors/fonts but no theme relationship exists",
              part: "word/document.xml",
              suggestion: "Add a theme relationship in document.xml.rels " \
                          "pointing to word/theme/theme1.xml."
            )
          end

          # DOC-081: Theme part well-formed
          if context.part_exists?("word/theme/theme1.xml")
            check_theme_well_formed(context, issues)
          end

          issues
        end

        private

        def check_theme_well_formed(context, issues)
          raw = context.part_raw("word/theme/theme1.xml")
          return unless raw

          doc = Nokogiri::XML(raw, &:strict)
          root = doc.root
          return if root&.name == "theme"

          issues << issue(
            "Theme part root element is not <a:theme>",
            code: "DOC-081",
            severity: "error",
            part: "word/theme/theme1.xml",
            suggestion: "The theme part should have <a:theme> as its " \
                        "root element per DrawingML specification."
          )
        rescue Nokogiri::XML::SyntaxError => e
          issues << issue(
            "Theme part is malformed: #{e.message}",
            code: "DOC-081",
            severity: "error",
            part: "word/theme/theme1.xml",
            suggestion: "Fix the XML syntax in the theme part."
          )
        end
      end
    end
  end
end
