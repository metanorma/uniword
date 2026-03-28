# frozen_string_literal: true

module Uniword
  module Builder
    # Builds Table of Contents for documents.
    #
    # @example Add a TOC to a document
    #   doc.paragraph do |p|
    #     p << Builder.toc('Table of Contents')
    #   end
    class TocBuilder
      # Create a TOC as structured content (paragraphs with field codes)
      #
      # @param title [String] TOC title
      # @param styles [Array<String>] Heading styles to include
      # @return [Array<Wordprocessingml::Paragraph>] TOC paragraphs
      def self.build(title: 'Table of Contents', styles: nil)
        paragraphs = []

        # Title paragraph
        title_para = Wordprocessingml::Paragraph.new
        title_run = Wordprocessingml::Run.new(text: title)
        title_para.runs << title_run
        paragraphs << title_para

        # TOC field paragraph
        toc_para = Wordprocessingml::Paragraph.new

        # Field begin
        begin_char = Wordprocessingml::FieldChar.new
        begin_char.fldCharType = 'begin'
        toc_para.field_chars << begin_char

        # Instruction text
        instr = Wordprocessingml::InstrText.new
        instr.text = " TOC \\o \"1-3\" \\h \\z \\u "
        toc_para.instr_text << instr

        # Field separate
        sep_char = Wordprocessingml::FieldChar.new
        sep_char.fldCharType = 'separate'
        toc_para.field_chars << sep_char

        # Field end
        end_char = Wordprocessingml::FieldChar.new
        end_char.fldCharType = 'end'
        toc_para.field_chars << end_char

        paragraphs << toc_para
        paragraphs
      end
    end
  end
end
