# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates font references.
      #
      # DOC-070: Fonts referenced in document.xml exist in fontTable.xml
      # DOC-071: Panose signatures present for non-symbol fonts
      class FontsRule < Base
        W_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

        def code = "DOC-070"
        def category = :fonts
        def severity = "notice"

        def applicable?(context)
          context.part_exists?("word/document.xml") &&
            context.part_exists?("word/fontTable.xml")
        end

        def check(context)
          issues = []
          doc = context.document_xml
          return issues unless doc

          ft = context.font_table_xml
          return issues unless ft

          # Collect defined font names
          defined_fonts = Set.new
          ft.root.xpath(".//w:font/@w:name", "w" => W_NS).each do |attr|
            defined_fonts << attr.value
          end

          # Collect referenced fonts from run properties
          referenced = Set.new
          doc.root.xpath(".//w:rFonts/@w:ascii", "w" => W_NS).each do |attr|
            referenced << attr.value
          end
          doc.root.xpath(".//w:rFonts/@w:hAnsi", "w" => W_NS).each do |attr|
            referenced << attr.value
          end
          doc.root.xpath(".//w:rFonts/@w:eastAsia", "w" => W_NS).each do |attr|
            referenced << attr.value
          end

          (referenced - defined_fonts).each do |font|
            issues << issue(
              "Font '#{font}' referenced but not in fontTable.xml",
              part: "word/document.xml",
              suggestion: "The font may render incorrectly. Add it to " \
                          "fontTable.xml or substitute with an available font."
            )
          end

          issues
        end
      end
    end
  end
end
