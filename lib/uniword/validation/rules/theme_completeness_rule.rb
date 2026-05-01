# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates theme fmtScheme has minimum required content.
      #
      # DOC-102: fmtScheme style lists must have minimum element counts
      # Validity rule: R3
      class ThemeCompletenessRule < Base
        A_NS = "http://schemas.openxmlformats.org/drawingml/2006/main"

        MINIMUM_COUNTS = {
          "fillStyleLst" => 2,
          "lnStyleLst" => 3,
          "effectStyleLst" => 3,
          "bgFillStyleLst" => 2,
        }.freeze

        def code = "DOC-102"
        def validity_rule = "R3"
        def description = "Theme fmtScheme must have minimum content in each style list"
        def category = :theme
        def severity = "error"

        def applicable?(context)
          context.part_exists?("word/theme/theme1.xml")
        end

        def check(context)
          issues = []
          doc = context.part("word/theme/theme1.xml")
          return issues unless doc

          fmt = doc.root.at_xpath(".//a:fmtScheme", "a" => A_NS)
          unless fmt
            issues << issue(
              "Theme missing <a:fmtScheme> element",
              part: "word/theme/theme1.xml",
            )
            return issues
          end

          MINIMUM_COUNTS.each do |list_name, minimum|
            list = fmt.at_xpath("a:#{list_name}", "a" => A_NS)
            unless list
              issues << issue(
                "Theme fmtScheme missing <a:#{list_name}> element",
                part: "word/theme/theme1.xml",
              )
              next
            end

            count = list.children.select(&:element?).count
            next if count >= minimum

            issues << issue(
              "Theme <a:#{list_name}> has #{count} elements, " \
              "minimum #{minimum} required",
              part: "word/theme/theme1.xml",
              suggestion: "Add #{minimum - count} more elements to <a:#{list_name}>.",
            )
          end

          issues
        end
      end
    end
  end
end
