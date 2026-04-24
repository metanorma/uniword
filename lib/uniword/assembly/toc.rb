# frozen_string_literal: true

module Uniword
  module Assembly
    # Table of Contents model.
    #
    # Represents a Word Table of Contents with configuration and entries.
    # This is a non-serializable model that generates serializable paragraphs.
    #
    # Following TODO.themes design principles:
    # - Non-Serializable Model: Has state + behavior, no direct XML serialization
    # - Generates serializable Paragraph objects for the document
    #
    # @example Create a TOC with default settings
    #   toc = Toc.new
    #   entries = toc.extract_entries(document)
    #   paragraphs = toc.generate_paragraphs(entries)
    #
    # @example Create a TOC with custom settings
    #   toc = Toc.new(
    #     max_level: 3,
    #     title: "Contents",
    #     include_page_numbers: true,
    #     create_hyperlinks: true
    #   )
    #   paragraphs = toc.generate_from_document(document)
    class Toc
      # @return [String] The TOC title
      attr_reader :title

      # @return [Integer] Maximum heading level to include (1-9)
      attr_reader :max_level

      # @return [Boolean] Whether to include page numbers
      attr_reader :include_page_numbers

      # @return [Boolean] Whether to create hyperlinks to headings
      attr_reader :create_hyperlinks

      # @return [TocInstruction, nil] The TOC field instruction
      attr_reader :instruction

      # @return [Array<TocEntry>] The TOC entries
      attr_reader :entries

      # Initialize a TOC.
      #
      # @param title [String] The TOC title (default: "Table of Contents")
      # @param max_level [Integer] Maximum heading level to include (1-9)
      # @param include_page_numbers [Boolean] Whether to include page numbers
      # @param create_hyperlinks [Boolean] Whether to create hyperlinks
      # @param instruction [TocInstruction, nil] Optional custom instruction
      def initialize(title: "Table of Contents",
                     max_level: 9,
                     include_page_numbers: true,
                     create_hyperlinks: true,
                     instruction: nil)
        @title = title
        @max_level = max_level
        @include_page_numbers = include_page_numbers
        @create_hyperlinks = create_hyperlinks
        @instruction = instruction || TocInstruction.new(outline_levels: "1-#{max_level}")
        @entries = []
      end

      # Extract TOC entries from a document.
      #
      # @param document [Wordprocessingml::DocumentRoot] The source document
      # @return [Array<TocEntry>] Extracted entries
      def extract_entries(document)
        @entries = []
        bookmark_counter = 0

        document.paragraphs.each_with_index do |paragraph, index|
          level = heading_level(paragraph)
          next unless level && level <= @max_level

          text = extract_text(paragraph)
          next if text.nil? || text.strip.empty?

          # Create bookmark name if creating hyperlinks
          bookmark_name = nil
          if @create_hyperlinks
            bookmark_counter += 1
            bookmark_name = "_Toc#{bookmark_counter}"
          end

          @entries << TocEntry.new(
            text: text.strip,
            level: level,
            paragraph_index: index,
            bookmark_name: bookmark_name,
          )
        end

        @entries
      end

      # Generate TOC paragraphs from entries.
      #
      # @return [Array<Wordprocessingml::Paragraph>] TOC paragraphs
      def generate_paragraphs
        paragraphs = []

        # Add title paragraph
        paragraphs << create_title_paragraph if @title && !@title.empty?

        # Add entry paragraphs
        @entries.each do |entry|
          paragraphs << entry.to_paragraph(include_page_numbers: @include_page_numbers)
        end

        paragraphs
      end

      # Generate TOC from document in one step.
      #
      # @param document [Wordprocessingml::DocumentRoot] The source document
      # @return [Array<Wordprocessingml::Paragraph>] TOC paragraphs
      def generate_from_document(document)
        extract_entries(document)
        generate_paragraphs
      end

      # Generate a new document containing the TOC.
      #
      # @param document [Wordprocessingml::DocumentRoot] The source document
      # @return [Wordprocessingml::DocumentRoot] New document with TOC
      def generate_document(document)
        toc_paragraphs = generate_from_document(document)

        # Create new document
        toc_doc = Wordprocessingml::DocumentRoot.new

        # Add TOC paragraphs
        toc_doc.body.paragraphs.concat(toc_paragraphs)

        toc_doc
      end

      # Insert TOC into document at position.
      #
      # @param document [Wordprocessingml::DocumentRoot] The target document
      # @param position [Integer] Insertion position (default: 0)
      # @return [void]
      def insert_into(document, position = 0)
        toc_paragraphs = generate_from_document(document)

        # Insert paragraphs at position (reverse to maintain order)
        toc_paragraphs.reverse.each do |para|
          document.paragraphs.insert(position, para)
        end
      end

      # Get the TOC field instruction string.
      #
      # @return [String] The instruction string
      def instruction_string
        @instruction&.to_s || "TOC \\o \"1-#{@max_level}\" \\h \\z"
      end

      private

      # Determine heading level of paragraph.
      #
      # @param paragraph [Wordprocessingml::Paragraph] Paragraph to check
      # @return [Integer, nil] Heading level or nil
      def heading_level(paragraph)
        style_name = paragraph.properties&.style
        return nil unless style_name

        # Check for heading styles (Heading 1, Heading 2, etc.)
        match = style_name.match(/^Heading\s*(\d+)$/i)
        return match[1].to_i if match

        # Check for outline level in properties
        if paragraph.properties.respond_to?(:outline_level)
          outline = paragraph.properties.outline_level
          return outline if outline.is_a?(Integer)
        end

        nil
      end

      # Extract text from paragraph.
      #
      # @param paragraph [Wordprocessingml::Paragraph] Source paragraph
      # @return [String] Extracted text
      def extract_text(paragraph)
        text_parts = []

        paragraph.runs.each do |run|
          run_text = run.text
          next unless run_text

          # Handle Text objects by converting to string
          text_parts << run_text.to_s
        end

        text_parts.join
      end

      # Create title paragraph.
      #
      # @return [Wordprocessingml::Paragraph] Title paragraph
      def create_title_paragraph
        para = Wordprocessingml::Paragraph.new
        para.properties ||= Wordprocessingml::ParagraphProperties.new
        para.properties.style = "TOCHeading"

        run = Wordprocessingml::Run.new
        run.text = @title

        # Set run properties
        if run.respond_to?(:properties=)
          run.properties = Wordprocessingml::RunProperties.new(
            bold: true,
            size: 48, # 24pt = 48 half-points
          )
        end

        para.runs << run
        para
      end
    end
  end
end
