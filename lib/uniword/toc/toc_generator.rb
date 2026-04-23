# frozen_string_literal: true

module Uniword
  module Toc
    # Orchestrator for Table of Contents operations.
    #
    # Scans a document for heading paragraphs, builds TocEntry objects,
    # inserts a TOC field into the document, and refreshes existing TOC fields.
    #
    # Heading detection looks at paragraph style references matching
    # "Heading1" through "Heading6" (case-insensitive, with or without
    # space between "Heading" and the digit).
    #
    # @example Generate entries from headings
    #   generator = TocGenerator.new(document)
    #   entries = generator.generate
    #   entries.each { |e| puts "#{e.level}: #{e.text}" }
    #
    # @example Insert a TOC field at the beginning
    #   generator = TocGenerator.new(document)
    #   entries = generator.generate
    #   generator.insert(entries, position: 0)
    #   document.save("output.docx")
    #
    # @example Update an existing TOC
    #   generator = TocGenerator.new(document)
    #   generator.update
    #   document.save("output.docx")
    class TocGenerator
      # Pattern matching heading style names like "Heading1" or "Heading 1"
      HEADING_PATTERN = /^Heading\s*(\d+)$/i

      # Maximum heading level recognized
      MAX_LEVEL = 6

      # @return [Wordprocessingml::DocumentRoot] The source document
      attr_reader :document

      # Initialize the generator with a document.
      #
      # @param document [Wordprocessingml::DocumentRoot] The document to operate on
      def initialize(document)
        @document = document
      end

      # Generate TOC entries by scanning paragraphs for heading styles.
      #
      # @param max_level [Integer] Maximum heading level to include (1-6)
      # @return [Array<TocEntry>] Extracted heading entries
      def generate(max_level: MAX_LEVEL)
        entries = []

        document.paragraphs.each_with_index do |paragraph, index|
          level = heading_level(paragraph)
          next unless level
          next if level > max_level

          text = extract_text(paragraph)
          next if text.nil? || text.strip.empty?

          style_name = resolve_style_name(paragraph)

          entries << TocEntry.new(
            level: level,
            text: text.strip,
            style_name: style_name,
            paragraph_index: index,
          )
        end

        entries
      end

      # Insert a TOC field into the document at the given position.
      #
      # Creates a Structured Document Tag (SDT) containing:
      # - A title paragraph ("Table of Contents")
      # - A TOC field instruction paragraph
      # - Placeholder paragraphs for each entry
      #
      # @param toc_entries [Array<TocEntry>] Entries to render
      # @param position [Integer] Insert position in the paragraph list
      # @param max_level [Integer] Maximum heading level for the field code
      # @return [void]
      def insert(toc_entries, position: 0, max_level: MAX_LEVEL)
        sdt = build_toc_sdt(toc_entries, max_level: max_level)

        body = document.body
        body.structured_document_tags << sdt

        # Add the SDT to element_order so it serializes correctly
        return unless body.element_order

        insert_element = Lutaml::Xml::Element.new("Element", "sdt")
        if position.positive? && body.element_order.size >= position
          body.element_order.insert(position, insert_element)
        else
          body.element_order.insert(0, insert_element)
        end
      end

      # Update an existing TOC in the document.
      #
      # Re-scans headings and rebuilds the first TOC SDT found.
      # If no existing TOC is found, does nothing and returns an empty array.
      #
      # @param max_level [Integer] Maximum heading level to include
      # @return [Array<TocEntry>] Updated entries, or empty if no TOC found
      def update(max_level: MAX_LEVEL)
        entries = generate(max_level: max_level)
        return [] if entries.empty?

        # Find the first TOC SDT in the body
        toc_sdt = find_toc_sdt
        return [] unless toc_sdt

        # Rebuild the SDT content
        rebuild_sdt_content(toc_sdt, entries, max_level: max_level)

        entries
      end

      private

      # Determine heading level from paragraph style.
      #
      # @param paragraph [Wordprocessingml::Paragraph] Paragraph to inspect
      # @return [Integer, nil] Heading level (1-6) or nil
      def heading_level(paragraph)
        style_name = resolve_style_name(paragraph)
        return nil unless style_name

        match = style_name.match(HEADING_PATTERN)
        return nil unless match

        level = match[1].to_i
        level <= MAX_LEVEL ? level : nil
      end

      # Extract the style name string from a paragraph.
      #
      # @param paragraph [Wordprocessingml::Paragraph] Paragraph to inspect
      # @return [String, nil] Style name or nil
      def resolve_style_name(paragraph)
        style_ref = paragraph.properties&.style
        return nil unless style_ref

        if style_ref.respond_to?(:value)
          style_ref.value
        else
          style_ref.to_s
        end
      end

      # Extract text content from a paragraph.
      #
      # @param paragraph [Wordprocessingml::Paragraph] Source paragraph
      # @return [String] Combined text from runs
      def extract_text(paragraph)
        paragraph.text
      end

      # Build a Structured Document Tag for the TOC.
      #
      # @param toc_entries [Array<TocEntry>] TOC entries to render
      # @param max_level [Integer] Maximum heading level
      # @return [Wordprocessingml::StructuredDocumentTag] The SDT
      def build_toc_sdt(toc_entries, max_level:)
        sdt = Wordprocessingml::StructuredDocumentTag.new

        # SDT properties
        sdt.properties = Wordprocessingml::StructuredDocumentTagProperties.new
        sdt.properties.id = Wordprocessingml::StructuredDocumentTag::Id.new(
          value: rand(100_000..999_999),
        )

        # SDT content with TOC paragraphs
        sdt.content = Wordprocessingml::StructuredDocumentTag::Content.new

        # Title paragraph
        sdt.content.paragraphs << build_title_paragraph

        # TOC field instruction paragraph
        sdt.content.paragraphs << build_toc_field_paragraph(max_level: max_level)

        # Placeholder entry paragraphs
        toc_entries.each do |entry|
          sdt.content.paragraphs << build_entry_paragraph(entry)
        end

        sdt
      end

      # Build the "Table of Contents" title paragraph.
      #
      # @return [Wordprocessingml::Paragraph]
      def build_title_paragraph
        para = Wordprocessingml::Paragraph.new
        para.properties = Wordprocessingml::ParagraphProperties.new
        para.properties.style = Uniword::Properties::StyleReference.new(
          value: "TOCHeading",
        )

        run = Wordprocessingml::Run.new
        run.text = "Table of Contents"
        para.runs << run

        para
      end

      # Build a paragraph containing the TOC field instruction.
      #
      # The field uses begin/separate/end markers around the
      # instruction text: TOC \o "1-N" \h \z \u
      #
      # @param max_level [Integer] Maximum heading level
      # @return [Wordprocessingml::Paragraph]
      def build_toc_field_paragraph(max_level: MAX_LEVEL)
        para = Wordprocessingml::Paragraph.new

        # Begin marker
        begin_char = Wordprocessingml::FieldChar.new(fldCharType: "begin")
        para.field_chars << begin_char

        # Instruction text
        instr = Wordprocessingml::InstrText.new(
          text: " TOC \\o \"1-#{max_level}\" \\h \\z \\u ",
        )
        para.instr_text << instr

        # Separate marker
        sep_char = Wordprocessingml::FieldChar.new(fldCharType: "separate")
        para.field_chars << sep_char

        # Placeholder run (displayed before Word updates the field)
        placeholder_run = Wordprocessingml::Run.new
        placeholder_run.text = "[Table of Contents]"
        para.runs << placeholder_run

        # End marker
        end_char = Wordprocessingml::FieldChar.new(fldCharType: "end")
        para.field_chars << end_char

        para
      end

      # Build a paragraph for a single TOC entry.
      #
      # @param entry [TocEntry] The entry to render
      # @return [Wordprocessingml::Paragraph]
      def build_entry_paragraph(entry)
        para = Wordprocessingml::Paragraph.new
        para.properties = Wordprocessingml::ParagraphProperties.new
        para.properties.style = Uniword::Properties::StyleReference.new(
          value: "TOC#{entry.level}",
        )

        run = Wordprocessingml::Run.new
        run.text = entry.text
        para.runs << run

        para
      end

      # Find the first SDT that looks like a TOC container.
      #
      # Looks for an SDT whose content contains an InstrText with
      # a TOC field instruction.
      #
      # @return [Wordprocessingml::StructuredDocumentTag, nil]
      def find_toc_sdt
        body = document.body
        return nil unless body

        sdts = body.structured_document_tags
        return nil unless sdts && !sdts.empty?

        sdts.find do |sdt|
          sdt.content&.paragraphs&.any? do |para|
            para.instr_text&.any? { |instr| instr.text.to_s.include?("TOC") }
          end
        end
      end

      # Rebuild the content of an existing TOC SDT.
      #
      # @param sdt [Wordprocessingml::StructuredDocumentTag] The TOC SDT
      # @param entries [Array<TocEntry>] New entries
      # @param max_level [Integer] Maximum heading level
      def rebuild_sdt_content(sdt, entries, max_level:)
        sdt.content = Wordprocessingml::StructuredDocumentTag::Content.new

        sdt.content.paragraphs << build_title_paragraph
        sdt.content.paragraphs << build_toc_field_paragraph(max_level: max_level)

        entries.each do |entry|
          sdt.content.paragraphs << build_entry_paragraph(entry)
        end
      end
    end
  end
end
