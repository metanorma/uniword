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

        has_content = paragraph.runs.any? ||
                      paragraph.hyperlinks.any? ||
                      paragraph.sdts.any?
        has_content ? paragraph : nil
      end

      # Build an OOXML Table from an HTML table element.
      #
      # Handles colspan → gridSpan and rowspan → vMerge with continuation
      # cell insertion. The grid layout is computed row-by-row to correctly
      # place vMerge continuation cells where HTML rowspan omits cells.
      #
      # @param html_table [Nokogiri::XML::Element] HTML table element
      # @return [Uniword::Wordprocessingml::Table, nil]
      def self.build_table(html_table)
        table = Uniword::Wordprocessingml::Table.new
        html_rows = html_table.css("tr")
        return nil if html_rows.empty?

        # Track columns occupied by rowspan: col_idx → remaining continuation rows
        occupied = {}
        rows = []

        html_rows.each do |html_row|
          row = Uniword::Wordprocessingml::TableRow.new
          col_idx = 0

          html_row.css("td, th").each do |html_cell|
            # Insert vMerge continuation cells for columns occupied by rowspan
            while occupied.key?(col_idx)
              row.cells << create_vmerge_continuation_cell
              occupied[col_idx] -= 1
              occupied.delete(col_idx) if occupied[col_idx] <= 0
              col_idx += 1
            end

            cell = build_cell(html_cell)
            row.cells << cell

            # Track rowspan for continuation cell insertion in subsequent rows
            rowspan = html_cell.attr("rowspan")&.to_i
            if rowspan && rowspan > 1
              colspan = html_cell.attr("colspan")&.to_i || 1
              colspan.times { |c| occupied[col_idx + c] = rowspan - 1 }
            end

            col_idx += (html_cell.attr("colspan")&.to_i || 1)
          end

          # Handle remaining occupied columns at end of row
          while occupied.key?(col_idx)
            row.cells << create_vmerge_continuation_cell
            occupied[col_idx] -= 1
            occupied.delete(col_idx) if occupied[col_idx] <= 0
            col_idx += 1
          end

          rows << row unless row.cells.empty?
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
      # Handles colspan → gridSpan, rowspan → vMerge restart, <th> → header.
      #
      # @param html_cell [Nokogiri::XML::Element] HTML td/th element
      # @return [Uniword::Wordprocessingml::TableCell, nil]
      def self.build_cell(html_cell)
        cell = Uniword::Wordprocessingml::TableCell.new

        # Detect <th> → header cell
        cell.header = html_cell.name.downcase == "th"

        # Handle colspan → gridSpan, rowspan → vMerge restart
        colspan = html_cell.attr("colspan")
        rowspan = html_cell.attr("rowspan")

        if (colspan && colspan.to_i > 1) || (rowspan && rowspan.to_i > 1)
          cell.properties ||= Uniword::Wordprocessingml::TableCellProperties.new
          if colspan && colspan.to_i > 1
            cell.properties.grid_span =
              Uniword::Wordprocessingml::ValInt.new(value: colspan.to_i)
          end
          if rowspan && rowspan.to_i > 1
            cell.properties.v_merge =
              Uniword::Wordprocessingml::ValInt.new(value: 1) # restart
          end
        end

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

      # Build child nodes (text nodes and element nodes) into runs/SDTs/hyperlinks.
      #
      # Handles: <br> → Break run, <a href> → Hyperlink, <span class="MsoFootnoteReference">
      # → FootnoteReference run, <span class="MsoEndnoteReference"> → EndnoteReference run.
      def self.build_children(paragraph, element)
        element.children.each do |child|
          case child.type
          when Nokogiri::XML::Node::TEXT_NODE
            text = child.text.strip
            next if text.empty?

            paragraph.runs << create_run(text)
          when Nokogiri::XML::Node::ELEMENT_NODE
            case child.name.downcase
            when "w:sdt", "sdt"
              sdt = create_sdt_from_element(child)
              paragraph.sdts << sdt if sdt
            when "br"
              paragraph.runs << create_break_run(child)
            when "a"
              hyperlink = create_hyperlink(child)
              paragraph.hyperlinks << hyperlink if hyperlink
            when "img"
              # Images require binary data not available from HTML parsing; skip
            when "span"
              if footnote_reference_span?(child)
                paragraph.runs << create_footnote_reference_run(child)
              elsif endnote_reference_span?(child)
                paragraph.runs << create_endnote_reference_run(child)
              else
                run = create_run_from_element(child)
                paragraph.runs << run if run
              end
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

      # Create a Run with Break from an HTML <br> element.
      #
      # @param element [Nokogiri::XML::Element] <br> element
      # @return [Uniword::Wordprocessingml::Run]
      def self.create_break_run(element)
        run = Uniword::Wordprocessingml::Run.new
        brk = Uniword::Wordprocessingml::Break.new
        style = element.attr("style").to_s
        clear = element.attr("clear").to_s
        if style.include?("page-break-before") || style.include?("page-break-after") || clear == "all"
          brk.type = "page"
        end
        run.break = brk
        run
      end

      # Check if element is a footnote reference span.
      #
      # @param element [Nokogiri::XML::Element]
      # @return [Boolean]
      def self.footnote_reference_span?(element)
        return false unless element.name.downcase == "span"

        element.attr("class").to_s.split.include?("MsoFootnoteReference")
      end

      # Check if element is an endnote reference span.
      #
      # @param element [Nokogiri::XML::Element]
      # @return [Boolean]
      def self.endnote_reference_span?(element)
        return false unless element.name.downcase == "span"

        element.attr("class").to_s.split.include?("MsoEndnoteReference")
      end

      # Create a Run with FootnoteReference from an HTML footnote reference span.
      #
      # @param element [Nokogiri::XML::Element] Span element with MsoFootnoteReference class
      # @return [Uniword::Wordprocessingml::Run]
      def self.create_footnote_reference_run(element)
        run = Uniword::Wordprocessingml::Run.new
        id = extract_note_id(element) || "1"
        run.footnote_reference =
          Uniword::Wordprocessingml::FootnoteReference.new(id: id)
        run
      end

      # Create a Run with EndnoteReference from an HTML endnote reference span.
      #
      # @param element [Nokogiri::XML::Element] Span element with MsoEndnoteReference class
      # @return [Uniword::Wordprocessingml::Run]
      def self.create_endnote_reference_run(element)
        run = Uniword::Wordprocessingml::Run.new
        id = extract_note_id(element) || "1"
        run.endnote_reference =
          Uniword::Wordprocessingml::EndnoteReference.new(id: id)
        run
      end

      # Extract footnote/endnote ID from reference span element.
      #
      # Tries: nested <a href="#_ftnN">, then text content digits.
      #
      # @param element [Nokogiri::XML::Element]
      # @return [String, nil]
      def self.extract_note_id(element)
        # Try nested <a href="#_ftnN"> or <a href="#_ednN">
        anchor = element.at_css("a[href^='#']")
        if anchor
          href = anchor.attr("href").sub(/^#/, "")
          if href =~ /(\d+)\s*$/
            return Regexp.last_match(1)
          end
        end

        # Fall back to digit in text content
        text = element.text.strip
        if text =~ /(\d+)/
          return Regexp.last_match(1)
        end

        nil
      end

      # Create a Hyperlink from an HTML <a href> element.
      #
      # @param element [Nokogiri::XML::Element] <a> element
      # @return [Uniword::Wordprocessingml::Hyperlink, nil]
      def self.create_hyperlink(element)
        href = element.attr("href")
        return nil unless href

        hyperlink = Uniword::Wordprocessingml::Hyperlink.new
        hyperlink.target = href

        element.children.each do |child|
          case child.type
          when Nokogiri::XML::Node::TEXT_NODE
            text = child.text.strip
            next if text.empty?

            hyperlink.runs << create_run(text)
          when Nokogiri::XML::Node::ELEMENT_NODE
            run = create_run_from_element(child)
            hyperlink.runs << run if run
          end
        end

        hyperlink.runs.any? ? hyperlink : nil
      end

      # Create a vMerge continuation cell (empty cell with vMerge, no val).
      #
      # @return [Uniword::Wordprocessingml::TableCell]
      def self.create_vmerge_continuation_cell
        cell = Uniword::Wordprocessingml::TableCell.new
        cell.properties = Uniword::Wordprocessingml::TableCellProperties.new
        cell.properties.v_merge = Uniword::Wordprocessingml::ValInt.new
        cell.paragraphs << Uniword::Wordprocessingml::Paragraph.new
        cell
      end
    end
  end
end
