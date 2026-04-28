# frozen_string_literal: true

module Uniword
  # Builder module provides a construction API for OOXML models.
  #
  # The Builder API orchestrates the creation and manipulation of OOXML model
  # objects without adding convenience methods to the model classes themselves.
  #
  # @example Build a document
  #   doc = Uniword::Builder::DocumentBuilder.new
  #   doc.paragraph { |p| p << 'Hello World' }
  #   doc.save('output.docx')
  #
  # @example Load and modify a document
  #   doc = Uniword::Builder::DocumentBuilder.from_file('input.docx')
  #   doc.paragraph { |p| p << 'Appended content' }
  #   doc.save('output.docx')
  module Builder
    autoload :DocumentBuilder, "uniword/builder/document_builder"
    autoload :ParagraphBuilder, "uniword/builder/paragraph_builder"
    autoload :RunBuilder, "uniword/builder/run_builder"
    autoload :TableBuilder, "uniword/builder/table_builder"
    autoload :TableRowBuilder, "uniword/builder/table_row_builder"
    autoload :TableCellBuilder, "uniword/builder/table_cell_builder"
    autoload :HeaderFooterBuilder, "uniword/builder/header_footer_builder"
    autoload :SectionBuilder, "uniword/builder/section_builder"
    autoload :StyleBuilder, "uniword/builder/style_builder"
    autoload :NumberingBuilder, "uniword/builder/numbering_builder"
    autoload :ImageBuilder, "uniword/builder/image_builder"
    autoload :CommentBuilder, "uniword/builder/comment_builder"
    autoload :TocBuilder, "uniword/builder/toc_builder"
    autoload :ListBuilder, "uniword/builder/list_builder"
    autoload :ThemeBuilder, "uniword/builder/theme_builder"
    autoload :FootnoteBuilder, "uniword/builder/footnote_builder"
    autoload :WatermarkBuilder, "uniword/builder/watermark_builder"
    autoload :SdtBuilder, "uniword/builder/sdt_builder"
    autoload :BibliographyBuilder, "uniword/builder/bibliography_builder"
    autoload :ChartBuilder, "uniword/builder/chart_builder"

    # Factory: creates a Run with optional formatting
    #
    # @param content [String] Text content
    # @param bold [Boolean] Bold formatting
    # @param italic [Boolean] Italic formatting
    # @param underline [String, Boolean] Underline style
    # @param color [String] Font color (hex)
    # @param size [Integer] Font size in points
    # @param font [String] Font name
    # @param highlight [String] Highlight color
    # @param strike [Boolean] Strikethrough
    # @param small_caps [Boolean] Small caps
    # @param caps [Boolean] All caps
    # @return [Wordprocessingml::Run]
    def self.text(content, **formatting)
      run = Wordprocessingml::Run.new(text: content)
      return run if formatting.empty?

      props = Wordprocessingml::RunProperties.new
      props.bold = Properties::Bold.new(value: true) if formatting[:bold]
      props.italic = Properties::Italic.new(value: true) if formatting[:italic]
      if formatting[:underline]
        val = formatting[:underline] == true ? "single" : formatting[:underline].to_s
        props.underline = Properties::Underline.new(value: val)
      end
      props.color = Properties::ColorValue.new(value: formatting[:color].to_s) if formatting[:color]
      props.size = Properties::FontSize.new(value: formatting[:size].to_i * 2) if formatting[:size]
      props.font = formatting[:font] if formatting[:font]
      props.highlight = Properties::Highlight.new(value: formatting[:highlight].to_s) if formatting[:highlight]
      props.strike = Properties::Strike.new(value: true) if formatting[:strike]
      props.small_caps = Properties::SmallCaps.new(value: true) if formatting[:small_caps]
      props.caps = Properties::Caps.new(value: true) if formatting[:caps]
      run.properties = props
      run
    end

    # Factory: creates a Hyperlink with optional text run
    #
    # @param target [String] URL or bookmark target
    # @param text [String, nil] Link display text
    # @param color [String] Link color (hex, default '0000FF')
    # @param underline [Boolean] Underline the link (default true)
    # @return [Wordprocessingml::Hyperlink]
    def self.hyperlink(target, text = nil, **options)
      hl = Wordprocessingml::Hyperlink.new
      hl.target = target
      if text
        color = options.fetch(:color, "0000FF")
        ul = options.fetch(:underline, true)
        run = self.text(text, color: color, underline: ul ? "single" : nil)
        hl.runs << run
      end
      hl
    end

    # Factory: creates a TabStop
    #
    # @param position [Integer] Tab position in twips
    # @param alignment [Symbol, String] :left, :center, :right, :decimal
    # @param leader [String, nil] Leader character style
    # @return [Properties::TabStop]
    def self.tab_stop(position:, alignment: :left, leader: nil)
      Properties::TabStop.new(
        position: position,
        alignment: alignment.to_s,
        leader: leader,
      )
    end

    # Factory: creates a Run containing an inline image Drawing
    # NOTE: This does NOT register the image in the document's image_parts.
    # Use DocumentBuilder#image instead for proper DOCX packaging.
    #
    # @param path [String] Path to image file
    # @param width [Integer, nil] Width in EMU
    # @param height [Integer, nil] Height in EMU
    # @return [Wordprocessingml::Run]
    def self.image(path, width: nil, height: nil)
      ImageBuilder.create_drawing(nil, path, width: width, height: height)
    end

    # Factory: creates a floating image Drawing
    # NOTE: This does NOT register the image in the document's image_parts.
    # Use DocumentBuilder#floating_image instead for proper DOCX packaging.
    #
    # @param path [String] Path to image file
    # @param width [Integer, nil] Width in EMU
    # @param height [Integer, nil] Height in EMU
    # @param align [Symbol, nil] Horizontal alignment
    # @param wrap [Symbol] Text wrapping style
    # @param behind_text [Boolean] Place behind text
    # @return [Wordprocessingml::Drawing]
    def self.floating_image(path, width: nil, height: nil, align: nil,
                            wrap: :square, behind_text: false)
      ImageBuilder.create_floating(nil, path, width: width, height: height,
                                              align: align, wrap: wrap,
                                              behind_text: behind_text)
    end

    # Factory: creates a page break Run
    #
    # @return [Wordprocessingml::Run]
    def self.page_break
      run = Wordprocessingml::Run.new
      run.break = Wordprocessingml::Break.new(type: "page")
      run
    end

    # Factory: creates a Run with a tab character
    #
    # @return [Wordprocessingml::Run]
    def self.tab
      run = Wordprocessingml::Run.new
      run.tab = Wordprocessingml::Tab.new
      run
    end

    # Factory: creates a Run containing a line break
    #
    # @return [Wordprocessingml::Run]
    def self.line_break
      run = Wordprocessingml::Run.new
      run.break = Wordprocessingml::Break.new(type: "line")
      run
    end

    # Factory: creates a paragraph containing a PAGE field
    #
    # @return [Wordprocessingml::Paragraph]
    def self.page_number_field
      build_field_paragraph(" PAGE ")
    end

    # Factory: creates a paragraph containing a NUMPAGES field
    #
    # @return [Wordprocessingml::Paragraph]
    def self.total_pages_field
      build_field_paragraph(" NUMPAGES ")
    end

    # Factory: creates a paragraph containing a DATE field
    #
    # @param format [String] Date format (default 'M/d/yyyy')
    # @return [Wordprocessingml::Paragraph]
    def self.date_field(format: "M/d/yyyy")
      build_field_paragraph(" DATE \\@ \"#{format}\" ")
    end

    # Factory: creates a paragraph containing a TIME field
    #
    # @param format [String] Time format (default 'h:mm:ss am/pm')
    # @return [Wordprocessingml::Paragraph]
    def self.time_field(format: "h:mm:ss am/pm")
      build_field_paragraph(" TIME \\@ \"#{format}\" ")
    end

    class << self
      private

      # Build a paragraph with a complex field (begin/instrText/separate/end)
      #
      # @param instruction [String] Field instruction text
      # @return [Wordprocessingml::Paragraph]
      def build_field_paragraph(instruction)
        para = Wordprocessingml::Paragraph.new

        # Begin character (inside a run wrapper)
        fc_begin = Wordprocessingml::FieldChar.new
        fc_begin.fldCharType = "begin"
        para.field_chars << fc_begin

        # Instruction text
        it = Wordprocessingml::InstrText.new
        it.text = instruction
        para.instr_text << it

        # Separate character
        fc_sep = Wordprocessingml::FieldChar.new
        fc_sep.fldCharType = "separate"
        para.field_chars << fc_sep

        # End character
        fc_end = Wordprocessingml::FieldChar.new
        fc_end.fldCharType = "end"
        para.field_chars << fc_end

        para
      end
    end
  end
end
