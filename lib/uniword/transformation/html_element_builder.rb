# frozen_string_literal: true

module Uniword
  module Transformation
    # Builds OOXML element objects from parsed HTML (Nokogiri nodes).
    #
    # Pure functions — no state, no side effects.
    # Used by HtmlToOoxmlConverter to construct OOXML paragraphs, tables, runs.
    #
    # Delegates formatting extraction to HtmlFormattingMapper.
    class HtmlElementBuilder
      # Build an OOXML Paragraph from an HTML element.
      #
      # @param element [Nokogiri::XML::Element] HTML element
      # @return [Uniword::Wordprocessingml::Paragraph, nil]
      def self.build_paragraph(element)
        paragraph = Uniword::Wordprocessingml::Paragraph.new

        apply_heading_style(paragraph, element)
        apply_css_style(paragraph, element)
        build_children(paragraph, element)

        paragraph.runs.any? ? paragraph : nil
      end

      # Build an OOXML Table from an HTML table element.
      #
      # @param html_table [Nokogiri::XML::Element] HTML table element
      # @return [Uniword::Wordprocessingml::Table, nil]
      def self.build_table(html_table)
        table = Uniword::Wordprocessingml::Table.new
        rows = []

        html_table.css("tr").each do |html_row|
          row = build_row(html_row)
          rows << row if row
        end

        return nil if rows.empty?

        rows.each { |r| table.rows << r }
        table
      end

      # Build an OOXML TableRow from an HTML tr element.
      #
      # @param html_row [Nokogiri::XML::Element] HTML tr element
      # @return [Uniword::Wordprocessingml::TableRow, nil]
      def self.build_row(html_row)
        row = Uniword::Wordprocessingml::TableRow.new
        cells = []

        html_row.css("td, th").each do |html_cell|
          cell = build_cell(html_cell)
          cells << cell if cell
        end

        return nil if cells.empty?

        cells.each { |c| row.cells << c }
        row
      end

      # Build an OOXML TableCell from an HTML td/th element.
      #
      # @param html_cell [Nokogiri::XML::Element] HTML td/th element
      # @return [Uniword::Wordprocessingml::TableCell, nil]
      def self.build_cell(html_cell)
        cell = Uniword::Wordprocessingml::TableCell.new

        # Convert cell content to paragraphs
        html_cell.css("p, div, h1, h2, h3, h4, h5, h6").each do |para_element|
          paragraph = build_paragraph(para_element)
          cell.paragraphs << paragraph if paragraph
        end

        # If no paragraphs found, create one from text content
        if cell.paragraphs.empty?
          text = html_cell.text.strip
          if text && !text.empty?
            para = Uniword::Wordprocessingml::Paragraph.new
            para.runs << create_run(text)
            cell.paragraphs << para
          end
        end

        # Always return a cell, even if empty (preserves table structure)
        cell.paragraphs.empty? ? ensure_empty_cell(cell) : cell
      end

      # Create a simple OOXML Run from text.
      #
      # @param text [String] Run text
      # @return [Uniword::Wordprocessingml::Run]
      def self.create_run(text)
        run = Uniword::Wordprocessingml::Run.new
        run.text = HtmlFormattingMapper.decode_entities(text)
        run
      end

      # Create an OOXML Run from an HTML element with inline formatting.
      #
      # @param element [Nokogiri::XML::Element] HTML element
      # @return [Uniword::Wordprocessingml::Run, nil]
      def self.create_run_from_element(element)
        text = element.text.strip
        return nil if text.empty?

        decoded_text = HtmlFormattingMapper.decode_entities(text)
        props = HtmlFormattingMapper.collect_formatting(element)

        run = Uniword::Wordprocessingml::Run.new
        run.text = decoded_text
        run.properties = props if HtmlFormattingMapper.has_formatting?(props)
        run
      end

      # Create an OOXML SDT from an HTML w:sdt element.
      #
      # @param element [Nokogiri::XML::Element] HTML w:sdt element
      # @return [Uniword::Wordprocessingml::StructuredDocumentTag, nil]
      def self.create_sdt_from_element(element)
        text = element.text.strip
        return nil if text.empty?

        sdt = Uniword::Wordprocessingml::StructuredDocumentTag.new
        sdt_props = parse_sdt_attributes(element)
        sdt.properties = sdt_props if sdt_props

        content = Uniword::Wordprocessingml::StructuredDocumentTag::Content.new
        run = Uniword::Wordprocessingml::Run.new
        run.text = HtmlFormattingMapper.decode_entities(text)
        content.runs = [run]
        sdt.content = content

        sdt
      end

      private

      # Apply heading level style from tag name (h1-h6).
      def self.apply_heading_style(paragraph, element)
        return unless element.name.match?(/^h[1-6]$/)

        paragraph.properties ||=
          Uniword::Wordprocessingml::ParagraphProperties.new
        heading_num = element.name[1]
        paragraph.properties.style = "Heading#{heading_num}"
      end

      # Apply CSS class → OOXML style mapping.
      def self.apply_css_style(paragraph, element)
        css_class = element.attr("class")
        return unless css_class && !css_class.empty?

        mapped_style = HtmlFormattingMapper.map_css_class_to_style(css_class)
        return unless mapped_style

        paragraph.properties ||=
          Uniword::Wordprocessingml::ParagraphProperties.new
        paragraph.properties.style = mapped_style
      end

      # Build child nodes (text nodes and element nodes) into runs/SDTs.
      def self.build_children(paragraph, element)
        element.children.each do |child|
          case child.type
          when Nokogiri::XML::Node::TEXT_NODE
            text = child.text.strip
            next if text.empty?

            paragraph.runs << create_run(text)
          when Nokogiri::XML::Node::ELEMENT_NODE
            if child.name.downcase == "w:sdt" || child.name == "sdt"
              sdt = create_sdt_from_element(child)
              paragraph.sdts << sdt if sdt
            else
              run = create_run_from_element(child)
              paragraph.runs << run if run
            end
          end
        end
      end

      # Ensure cell has at least one empty paragraph to preserve structure.
      def self.ensure_empty_cell(cell)
        cell.paragraphs << Uniword::Wordprocessingml::Paragraph.new
        cell
      end

      # Parse SDT attributes from HTML element.
      def self.parse_sdt_attributes(element)
        attrs = element.attributes
        return nil if attrs.empty?

        sdt_props =
          Uniword::Wordprocessingml::StructuredDocumentTagProperties.new

        if attrs["showingplchdr"] || attrs["ShowingPlcHdr"]
          sdt_props.showing_placeholder_header =
            Uniword::Wordprocessingml::StructuredDocumentTag::ShowingPlaceholderHeader.new
        end

        if attrs["temporary"] || attrs["Temporary"]
          sdt_props.temporary =
            Uniword::Wordprocessingml::StructuredDocumentTag::Temporary.new
        end

        doc_part = attrs["docpart"] || attrs["DocPart"]
        if doc_part
          placeholder =
            Uniword::Wordprocessingml::StructuredDocumentTag::Placeholder.new
          doc_part_ref =
            Uniword::Wordprocessingml::StructuredDocumentTag::DocPartReference.new(value: doc_part.value)
          placeholder.doc_part = doc_part_ref
          sdt_props.placeholder = placeholder
        end

        if attrs["text"] || attrs["Text"]
          sdt_props.text =
            Uniword::Wordprocessingml::StructuredDocumentTag::Text.new(value: "whole")
        end

        id_attr = attrs["id"] || attrs["ID"]
        if id_attr
          sdt_props.id =
            Uniword::Wordprocessingml::StructuredDocumentTag::Id.new(value: id_attr.value.to_i)
        end

        if attrs["bibliography"] || attrs["Bibliography"]
          sdt_props.bibliography =
            Uniword::Wordprocessingml::StructuredDocumentTag::Bibliography.new
        end

        sdt_props
      end
    end
  end
end
