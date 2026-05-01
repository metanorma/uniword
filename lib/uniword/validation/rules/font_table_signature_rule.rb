# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates font table signature completeness.
      #
      # DOC-107: Font sig elements should have valid attributes
      # Validity rule: R13
      class FontTableSignatureRule < Base
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

        SIG_ATTRS = %w[usb0 usb1 usb2 usb3 csb0 csb1].freeze

        def code = "DOC-107"
        def validity_rule = "R13"
        def description = "Font table sig elements should have valid attributes"
        def category = :fonts
        def severity = "warning"

        def applicable?(context)
          context.part_exists?("word/fontTable.xml")
        end

        def check(context)
          issues = []
          doc = context.font_table_xml
          return issues unless doc

          doc.root.xpath(".//w:font", "w" => W_NS).each do |font|
            name = font["w:name"]
            sig = font.at_xpath("w:sig", "w" => W_NS)

            next unless sig

            missing = SIG_ATTRS.reject { |attr| sig["w:#{attr}"] }

            next if missing.empty?

            issues << issue(
              "Font '#{name}' sig element missing attributes: #{missing.join(', ')}",
              part: "word/fontTable.xml",
              severity: "warning",
              suggestion: "Add complete sig data for font '#{name}'.",
            )
          end

          issues
        end
      end
    end
  end
end
