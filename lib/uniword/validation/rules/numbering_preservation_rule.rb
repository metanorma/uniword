# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates numbering elements are properly structured.
      #
      # DOC-103: Level elements and lvlOverride are consistent
      # Validity rules: R4, R5
      class NumberingPreservationRule < Base
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

        LEVEL_CHILDREN = %w[start numFmt suff lvlRestart lvlText lvlJc pPr ind
                            rPr].freeze

        def code = "DOC-103"
        def validity_rule = "R4"
        def description = "Numbering level elements and lvlOverride/startOverride are properly structured"
        def category = :numbering
        def severity = "warning"

        def applicable?(context)
          context.part_exists?("word/numbering.xml")
        end

        def check(context)
          issues = []
          doc = context.numbering_xml
          return issues unless doc

          check_abstract_num_integrity(doc, issues)
          check_num_instance_integrity(doc, issues)
          check_ilvl_range(doc, issues)
          check_lvl_overrides(doc, issues)

          issues
        end

        private

        def check_abstract_num_integrity(doc, issues)
          doc.root.xpath(".//w:abstractNum", "w" => W_NS).each do |abs|
            abs_id = abs["w:abstractNumId"]
            levels = abs.xpath("w:lvl", "w" => W_NS)

            next unless levels.empty?

            issues << issue(
              "Abstract numbering #{abs_id} has no levels defined",
              part: "word/numbering.xml",
              severity: "warning",
              code: "DOC-103",
            )
          end
        end

        def check_num_instance_integrity(doc, issues)
          doc.root.xpath(".//w:num", "w" => W_NS).each do |num|
            num_id = num["w:numId"]
            abs_ref = num.at_xpath("w:abstractNumId/@w:val", "w" => W_NS)

            unless abs_ref
              issues << issue(
                "Numbering instance numId=#{num_id} missing abstractNumId reference",
                part: "word/numbering.xml",
                code: "DOC-103",
              )
              next
            end

            # Check that referenced abstractNum exists
            abs_id = abs_ref.value
            abs_exists = doc.root.at_xpath(
              ".//w:abstractNum[@w:abstractNumId='#{abs_id}']", "w" => W_NS
            )

            next if abs_exists

            issues << issue(
              "Numbering instance numId=#{num_id} references " \
              "non-existent abstractNumId #{abs_id}",
              part: "word/numbering.xml",
              code: "DOC-103",
            )
          end
        end

        def check_ilvl_range(doc, issues)
          doc.root.xpath(".//w:lvl/@w:ilvl", "w" => W_NS).each do |attr|
            ilvl = attr.value.to_i
            next if ilvl.between?(0, 8)

            issues << issue(
              "Level ilvl=#{ilvl} is out of valid range (0-8)",
              part: "word/numbering.xml",
              severity: "warning",
              code: "DOC-103",
            )
          end
        end

        # R5: Check lvlOverride/startOverride inside num instances
        def check_lvl_overrides(doc, issues)
          doc.root.xpath(".//w:num", "w" => W_NS).each do |num|
            num_id = num["w:numId"]
            overrides = num.xpath("w:lvlOverride", "w" => W_NS)

            overrides.each do |ov|
              ilvl = ov["w:ilvl"]
              unless ilvl
                issues << issue(
                  "lvlOverride in numId=#{num_id} missing w:ilvl attribute",
                  part: "word/numbering.xml",
                  code: "DOC-103",
                )
              end

              start_ov = ov.at_xpath("w:startOverride", "w" => W_NS)
              next unless start_ov

              start_val = start_ov["w:val"]
              if start_val && start_val.to_i < 1
                issues << issue(
                  "startOverride in numId=#{num_id} lvlOverride ilvl=#{ilvl} " \
                  "has invalid val=#{start_val} (must be >= 1)",
                  part: "word/numbering.xml",
                  severity: "warning",
                  code: "DOC-103",
                )
              end
            end
          end
        end
      end
    end
  end
end
