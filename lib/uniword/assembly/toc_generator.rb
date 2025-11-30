# frozen_string_literal: true

module Uniword
  module Assembly
    # Generates table of contents from document headings.
    #
    # Responsibility: Create TOC from document structure.
    # Single Responsibility: Only handles TOC generation.
    #
    # The TocGenerator:
    # - Extracts headings from document
    # - Creates TOC entries with page references
    # - Supports configurable depth levels
    # - Maintains heading hierarchy
    # - Generates formatted TOC paragraphs
    #
    # @example Basic TOC generation
    #   gen = TocGenerator.new
    #   toc = gen.generate(document)
    #
    # @example With depth limit
    #   gen = TocGenerator.new(max_level: 3)
    #   toc = gen.generate(document)
    class TocGenerator
      # @return [Integer] Maximum heading level to include
      attr_reader :max_level

      # @return [String] TOC title
      attr_reader :title

      # Initialize TOC generator.
      #
      # @param max_level [Integer] Maximum heading level (1-9)
      # @param title [String] TOC title
      # @param include_page_numbers [Boolean] Include page numbers
      #
      # @example Create generator
      #   gen = TocGenerator.new
      #
      # @example Custom configuration
      #   gen = TocGenerator.new(
      #     max_level: 3,
      #     title: "Contents"
      #   )
      def initialize(max_level: 9, title: 'Table of Contents',
                     include_page_numbers: true)
        @max_level = max_level
        @title = title
        @include_page_numbers = include_page_numbers
      end

      # Generate TOC from document.
      #
      # @param document [Document] Source document
      # @return [Array<Paragraph>] TOC paragraphs
      #
      # @example Generate TOC
      #   toc_paragraphs = gen.generate(document)
      def generate(document)
        headings = extract_headings(document)
        create_toc_paragraphs(headings)
      end

      # Generate TOC as new document.
      #
      # @param document [Document] Source document
      # @return [Document] New document with TOC
      #
      # @example Generate TOC document
      #   toc_doc = gen.generate_document(document)
      def generate_document(document)
        toc_paragraphs = generate(document)

        # Create new document
        toc_doc = Document.new

        # Add TOC paragraphs
        toc_paragraphs.each do |para|
          toc_doc.add_paragraph(para)
        end

        toc_doc
      end

      # Insert TOC into document at position.
      #
      # @param document [Document] Target document
      # @param position [Integer] Insertion position
      # @return [void]
      #
      # @example Insert TOC at beginning
      #   gen.insert_toc(document, 0)
      def insert_toc(document, position = 0)
        toc_paragraphs = generate(document)

        # Insert paragraphs at position
        toc_paragraphs.reverse.each do |para|
          document.paragraphs.insert(position, para)
        end
      end

      private

      # Extract headings from document.
      #
      # @param document [Document] Source document
      # @return [Array<Hash>] Heading information
      def extract_headings(document)
        headings = []

        document.paragraphs.each_with_index do |paragraph, index|
          level = heading_level(paragraph)

          next unless level && level <= @max_level

          headings << {
            text: extract_text(paragraph),
            level: level,
            index: index,
            paragraph: paragraph
          }
        end

        headings
      end

      # Determine heading level of paragraph.
      #
      # @param paragraph [Paragraph] Paragraph to check
      # @return [Integer, nil] Heading level or nil
      def heading_level(paragraph)
        style_name = paragraph.style
        return nil unless style_name

        # Check for heading styles (Heading 1, Heading 2, etc.)
        match = style_name.match(/^Heading\s*(\d+)$/i)
        return match[1].to_i if match

        # Check for outline level
        return paragraph.properties.outline_level if paragraph.properties&.outline_level

        nil
      end

      # Extract text from paragraph.
      #
      # @param paragraph [Paragraph] Source paragraph
      # @return [String] Extracted text
      def extract_text(paragraph)
        text = ''

        paragraph.runs.each do |run|
          text += run.text if run.text
        end

        text.strip
      end

      # Create TOC paragraphs from headings.
      #
      # @param headings [Array<Hash>] Heading information
      # @return [Array<Paragraph>] TOC paragraphs
      def create_toc_paragraphs(headings)
        paragraphs = []

        # Add title
        if @title && !@title.empty?
          title_para = create_title_paragraph
          paragraphs << title_para
        end

        # Add heading entries
        headings.each do |heading|
          entry_para = create_entry_paragraph(heading)
          paragraphs << entry_para
        end

        paragraphs
      end

      # Create title paragraph.
      #
      # @return [Paragraph] Title paragraph
      def create_title_paragraph
        para = Paragraph.new
        para.style = 'TOCHeading'

        run = Run.new
        run.text = @title

        # Set run properties
        if run.respond_to?(:properties=)
          require_relative '../properties/run_properties'
          run.properties = Properties::RunProperties.new(
            bold: true,
            size: 48 # 24pt = 48 half-points
          )
        end

        para.add_run(run)
        para
      end

      # Create entry paragraph for heading.
      #
      # @param heading [Hash] Heading information
      # @return [Paragraph] Entry paragraph
      def create_entry_paragraph(heading)
        para = Paragraph.new
        para.style = "TOC#{heading[:level]}"

        # Add indentation based on level
        para.indent_left = (heading[:level] - 1) * 360

        # Add heading text
        text_run = Run.new
        text_run.text = heading[:text]
        para.add_run(text_run)

        # Add page number if enabled
        if @include_page_numbers
          # Add tab
          tab_run = Run.new
          tab_run.text = "\t"
          para.add_run(tab_run)

          # Add page number placeholder
          page_run = Run.new
          page_run.text = '1' # Placeholder - would be updated by Word
          para.add_run(page_run)
        end

        para
      end
    end
  end
end
