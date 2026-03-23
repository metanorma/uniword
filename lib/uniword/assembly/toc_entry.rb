# frozen_string_literal: true

module Uniword
  module Assembly
    # Represents a single entry in the Table of Contents.
    #
    # Each entry contains the heading text, level, and reference to the source paragraph.
    #
    # @example Create a TOC entry
    #   entry = TocEntry.new(
    #     text: "Chapter 1",
    #     level: 1,
    #     bookmark_name: "_Toc1"
    #   )
    class TocEntry
      # @return [String] The heading text
      attr_reader :text

      # @return [Integer] The heading level (1-9)
      attr_reader :level

      # @return [Integer] The paragraph index in the document
      attr_reader :paragraph_index

      # @return [String, nil] The bookmark name for linking
      attr_reader :bookmark_name

      # @return [Integer, nil] The page number (placeholder, updated by Word)
      attr_reader :page_number

      # Initialize a TOC entry.
      #
      # @param text [String] The heading text
      # @param level [Integer] The heading level (1-9)
      # @param paragraph_index [Integer] The paragraph index
      # @param bookmark_name [String, nil] Optional bookmark name
      # @param page_number [Integer, nil] Optional page number
      def initialize(text:, level:, paragraph_index:, bookmark_name: nil, page_number: nil)
        @text = text
        @level = level
        @paragraph_index = paragraph_index
        @bookmark_name = bookmark_name
        @page_number = page_number
      end

      # Create a paragraph for this TOC entry.
      #
      # @param include_page_numbers [Boolean] Whether to include page numbers
      # @return [Wordprocessingml::Paragraph] The paragraph
      def to_paragraph(include_page_numbers: true)
        para = Wordprocessingml::Paragraph.new
        para.style = "TOC#{@level}"

        # Add indentation based on level (360 twips = 0.25 inch per level)
        para.indent_left = (@level - 1) * 360

        # Add hyperlink if bookmark exists
        if @bookmark_name
          add_hyperlink_entry(para, include_page_numbers)
        else
          add_simple_entry(para, include_page_numbers)
        end

        para
      end

      private

      # Add simple entry without hyperlink.
      #
      # @param para [Wordprocessingml::Paragraph] The paragraph
      # @param include_page_numbers [Boolean] Whether to include page numbers
      def add_simple_entry(para, include_page_numbers)
        # Add heading text
        text_run = Wordprocessingml::Run.new
        text_run.text = @text
        para.add_run(text_run)

        if include_page_numbers
          add_page_number_run(para)
        end
      end

      # Add entry with hyperlink to bookmark.
      #
      # @param para [Wordprocessingml::Paragraph] The paragraph
      # @param include_page_numbers [Boolean] Whether to include page numbers
      def add_hyperlink_entry(para, include_page_numbers)
        # Create hyperlink
        hyperlink = Wordprocessingml::Hyperlink.new
        hyperlink.anchor = @bookmark_name

        # Add run with text to hyperlink
        text_run = Wordprocessingml::Run.new
        text_run.text = @text
        hyperlink.add_run(text_run)

        para.add_hyperlink(hyperlink)

        if include_page_numbers
          add_page_number_run(para)
        end
      end

      # Add page number run.
      #
      # @param para [Wordprocessingml::Paragraph] The paragraph
      def add_page_number_run(para)
        # Add tab
        tab_run = Wordprocessingml::Run.new
        tab_run.text = "\t"
        para.add_run(tab_run)

        # Add page number placeholder
        page_run = Wordprocessingml::Run.new
        page_run.text = @page_number.to_s
        para.add_run(page_run)
      end
    end
  end
end
