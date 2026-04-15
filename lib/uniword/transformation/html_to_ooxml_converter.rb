# frozen_string_literal: true

module Uniword
  module Transformation
    # SERVICE for converting HTML to OOXML elements.
    #
    # Pure functions - no state, no side effects.
    # Used by Transformer when source_format is :mhtml.
    #
    class HtmlToOoxmlConverter
      # Convert HTML content to OOXML paragraphs
      #
      # @param html_content [String] HTML content (may include full HTML document)
      # @return [Array<Uniword::Wordprocessingml::Paragraph>] Array of paragraphs
      def self.html_to_paragraphs(html_content)
        return [] if html_content.nil? || html_content.empty?

        # Extract body content if full HTML document
        body = extract_body(html_content)

        # Parse HTML and extract paragraphs
        doc = Nokogiri::HTML(body)
        paragraphs = []

        doc.css("p, h1, h2, h3, h4, h5, h6, li, div, tr").each do |element|
          # Skip elements that are inside table cells (table content is handled separately)
          next if element.ancestors("td, th").any?

          # Skip table row/cell containers themselves
          next if %w[tr td].include?(element.name)

          # Skip container elements (div, li) that have children matching the same selector.
          # This prevents duplicate processing when a div contains a p, since the p's
          # content is more semantically meaningful and the div's text would duplicate it.
          if %w[div
                li].include?(element.name) && element.css("p, h1, h2, h3, h4, h5, h6, li, div, tr").any?
            next
          end

          paragraph = html_element_to_paragraph(element)
          paragraphs << paragraph if paragraph
        end

        paragraphs
      end

      # Convert HTML content to OOXML tables
      #
      # @param html_content [String] HTML content (may include full HTML document)
      # @return [Array<Uniword::Wordprocessingml::Table>] Array of tables
      def self.html_to_tables(html_content)
        return [] if html_content.nil? || html_content.empty?

        # Extract body content if full HTML document
        body = extract_body(html_content)

        # Parse HTML and extract tables
        doc = Nokogiri::HTML(body)
        tables = []

        doc.css("table").each do |html_table|
          table = html_table_to_table(html_table)
          tables << table if table
        end

        tables
      end

      # Convert a single HTML table to OOXML table
      #
      # @param html_table [Nokogiri::XML::Element] HTML table element
      # @return [Uniword::Wordprocessingml::Table, nil] OOXML table or nil
      def self.html_table_to_table(html_table)
        table = Uniword::Wordprocessingml::Table.new
        rows = []

        html_table.css("tr").each do |html_row|
          row = html_row_to_row(html_row)
          rows << row if row
        end

        return nil if rows.empty?

        rows.each { |r| table.rows << r }
        table
      end

      # Convert a single HTML row to OOXML table row
      #
      # @param html_row [Nokogiri::XML::Element] HTML tr element
      # @return [Uniword::Wordprocessingml::TableRow, nil] OOXML row or nil
      def self.html_row_to_row(html_row)
        row = Uniword::Wordprocessingml::TableRow.new
        cells = []

        html_row.css("td, th").each do |html_cell|
          cell = html_cell_to_cell(html_cell)
          cells << cell if cell
        end

        return nil if cells.empty?

        cells.each { |c| row.cells << c }
        row
      end

      # Convert a single HTML cell to OOXML table cell
      #
      # @param html_cell [Nokogiri::XML::Element] HTML td/th element
      # @return [Uniword::Wordprocessingml::TableCell, nil] OOXML cell or nil
      def self.html_cell_to_cell(html_cell)
        cell = Uniword::Wordprocessingml::TableCell.new

        # Map CSS class to cell style if present
        css_class = html_cell.attr("class")
        if css_class && !css_class.empty?
          map_css_class_to_style(css_class)
          # Style mapping available if needed for cell-level styling
        end

        # Convert cell content to paragraphs
        html_cell.css("p, div, h1, h2, h3, h4, h5, h6").each do |para_element|
          paragraph = html_element_to_paragraph(para_element)
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
        cell.paragraphs.empty? ? create_empty_cell(cell) : cell
      end

      # Create a cell with an empty paragraph to preserve structure
      def self.create_empty_cell(cell)
        # Ensure at least one empty paragraph exists to represent the cell
        cell.paragraphs << Uniword::Wordprocessingml::Paragraph.new
        cell
      end

      # Convert a single HTML element to OOXML paragraph
      #
      # @param element [Nokogiri::XML::Element] HTML element
      # @return [Uniword::Wordprocessingml::Paragraph] OOXML paragraph
      def self.html_element_to_paragraph(element)
        paragraph = Uniword::Wordprocessingml::Paragraph.new

        # Determine heading level from tag name
        if element.name.match?(/^h[1-6]$/)
          paragraph.properties ||= Uniword::Wordprocessingml::ParagraphProperties.new
          heading_num = element.name[1]
          paragraph.properties.style = "Heading#{heading_num}"
        end

        # Map CSS class to OOXML style (MHT-specific classes)
        css_class = element.attr("class")
        if css_class && !css_class.empty?
          mapped_style = map_css_class_to_style(css_class)
          if mapped_style
            paragraph.properties ||= Uniword::Wordprocessingml::ParagraphProperties.new
            paragraph.properties.style = mapped_style
          end
        end

        # Convert child nodes to runs
        element.children.each do |child|
          case child.type
          when Nokogiri::XML::Node::TEXT_NODE
            text = child.text.strip
            next if text.empty?

            run = create_run(text)
            paragraph.runs << run
          when Nokogiri::XML::Node::ELEMENT_NODE
            # Handle SDT elements separately from runs
            if child.name.downcase == "w:sdt" || child.name == "sdt"
              sdt = create_sdt_from_element(child)
              paragraph.sdts << sdt if sdt
            else
              run = create_run_from_element(child)
              paragraph.runs << run if run
            end
          end
        end

        # Only return paragraph if it has content
        paragraph.runs.any? ? paragraph : nil
      end

      # Map MHT CSS class to OOXML style name
      #
      # @param css_class [String] CSS class string (may contain multiple classes)
      # @return [String, nil] OOXML style name or nil
      def self.map_css_class_to_style(css_class)
        # CSS class to OOXML style mapping for MHT documents
        class_mapping = {
          # Microsoft Office Built-in Styles
          "MsoTitle" => "Title",
          "MsoTitle2" => "Title2",
          "MsoSubtitle" => "Subtitle",
          "MsoHeading1" => "Heading1",
          "MsoHeading2" => "Heading2",
          "MsoHeading3" => "Heading3",
          "MsoHeading4" => "Heading4",
          "MsoHeading5" => "Heading5",
          "MsoHeading6" => "Heading6",
          "MsoToc1" => "TOC1",
          "MsoToc2" => "TOC2",
          "MsoToc3" => "TOC3",
          "MsoToc4" => "TOC4",
          "MsoToc5" => "TOC5",
          "MsoToc6" => "TOC6",
          "MsoToc7" => "TOC7",
          "MsoToc8" => "TOC8",
          "MsoToc9" => "TOC9",
          "MsoTocHeading" => "TOC Heading",
          "MsoBibliography" => "Bibliography",
          "MsoNoSpacing" => "No Spacing",
          "MsoQuote" => "Quote",
          "MsoHeader" => "Header",
          "MsoFooter" => "Footer",
          "MsoListBullet" => "List Bullet",
          "MsoCaption" => "Caption",
          "MsoEndnoteText" => "EndnoteText",
          "MsoFootnoteText" => "FootnoteText",
          "MsoPageBreak" => "PageBreak",

          # Table-related styles
          "TableNote" => "TableNote",
          "TableSource" => "TableSource",
          "TableTitle" => "TableTitle",
          "TableFigure" => "TableFigure",

          # Document part styles
          "SectionTitle" => "SectionTitle",
          "Heading4Char" => "Heading4Char",
          "Author" => "Author",

          # Direct class matches (non-Mso prefixed)
          "Title" => "Title",
          "Heading1" => "Heading1",
          "Heading2" => "Heading2",
          "Heading3" => "Heading3",
          "Heading4" => "Heading4",
          "Heading5" => "Heading5",
          "Heading6" => "Heading6",
          "Quote" => "Quote",
          "Bibliography" => "Bibliography",
          "NoSpacing" => "No Spacing"
        }

        # Check each class in the class string
        css_class.split.each do |cls|
          return class_mapping[cls] if class_mapping.key?(cls)
        end

        nil
      end

      # Create OOXML run from HTML element with inline formatting
      #
      # @param element [Nokogiri::XML::Element] HTML element
      # @return [Uniword::Wordprocessingml::Run, nil] OOXML Run or nil
      def self.create_run_from_element(element)
        text = element.text.strip
        return nil if text.empty?

        # Decode HTML entities (e.g., &copy; -> ©)
        decoded_text = decode_html_entities(text)

        # Recursively collect formatting from nested elements
        props = collect_formatting_from_element(element)

        run = Uniword::Wordprocessingml::Run.new
        run.text = decoded_text
        run.properties = props if has_properties?(props)
        run
      end

      # Create OOXML SDT from HTML element
      #
      # @param element [Nokogiri::XML::Element] HTML w:sdt element
      # @return [Uniword::Wordprocessingml::StructuredDocumentTag, nil] OOXML SDT or nil
      def self.create_sdt_from_element(element)
        text = element.text.strip
        return nil if text.empty?

        sdt = Uniword::Wordprocessingml::StructuredDocumentTag.new

        # Parse SDT attributes
        sdt_props = parse_sdt_attributes(element)
        sdt.properties = sdt_props if sdt_props

        # Create SDT content with the text
        content = Uniword::Wordprocessingml::StructuredDocumentTag::Content.new
        run = Uniword::Wordprocessingml::Run.new
        run.text = decode_html_entities(text)
        content.runs = [run]
        sdt.content = content

        sdt
      end

      # Parse SDT attributes from HTML element
      #
      # @param element [Nokogiri::XML::Element] HTML w:sdt element
      # @return [Uniword::Wordprocessingml::StructuredDocumentTagProperties, nil]
      def self.parse_sdt_attributes(element)
        attrs = element.attributes
        return nil if attrs.empty?

        sdt_props = Uniword::Wordprocessingml::StructuredDocumentTagProperties.new

        # ShowingPlcHdr - placeholder display flag
        if attrs["showingplchdr"] || attrs["ShowingPlcHdr"]
          sdt_props.showing_placeholder_header =
            Uniword::Wordprocessingml::StructuredDocumentTag::ShowingPlaceholderHeader.new
        end

        # Temporary - temporary SDT flag
        if attrs["temporary"] || attrs["Temporary"]
          sdt_props.temporary =
            Uniword::Wordprocessingml::StructuredDocumentTag::Temporary.new
        end

        # DocPart - document part UUID
        doc_part = attrs["docpart"] || attrs["DocPart"]
        if doc_part
          placeholder = Uniword::Wordprocessingml::StructuredDocumentTag::Placeholder.new
          doc_part_ref = Uniword::Wordprocessingml::StructuredDocumentTag::DocPartReference.new(value: doc_part.value)
          placeholder.doc_part = doc_part_ref
          sdt_props.placeholder = placeholder
        end

        # Text - text-only flag
        sdt_props.text = Uniword::Wordprocessingml::StructuredDocumentTag::Text.new(value: "whole") if attrs["text"] || attrs["Text"]

        # ID - numeric ID
        id_attr = attrs["id"] || attrs["ID"]
        sdt_props.id = Uniword::Wordprocessingml::StructuredDocumentTag::Id.new(value: id_attr.value.to_i) if id_attr

        # SdtDocPart - SDT document part type
        sdt_doc_part = attrs["sdtdocpart"] || attrs["SdtDocPart"]
        if sdt_doc_part
          # This is a special attribute indicating the SDT is a document part
        end

        # DocPartType - document part type (e.g., "Table of Contents")
        doc_part_type = attrs["docparttype"] || attrs["DocPartType"]
        if doc_part_type
          # Store as tag or alias
        end

        # Bibliography - bibliography flag
        if attrs["bibliography"] || attrs["Bibliography"]
          sdt_props.bibliography =
            Uniword::Wordprocessingml::StructuredDocumentTag::Bibliography.new
        end

        sdt_props
      end

      # Recursively collect formatting properties from element and its children
      #
      # @param element [Nokogiri::XML::Element] HTML element
      # @return [Uniword::Wordprocessingml::RunProperties] Run properties with all formatting
      def self.collect_formatting_from_element(element)
        props = Uniword::Wordprocessingml::RunProperties.new

        case element.name.downcase
        when "strong", "b"
          props.bold = Uniword::Properties::Bold.new
        when "em", "i"
          props.italic = Uniword::Properties::Italic.new
        when "u"
          props.underline = Uniword::Properties::Underline.new
        when "s", "strike"
          props.strike = Uniword::Properties::Strike.new
        when "sup"
          props.vertical_align = Uniword::Properties::VerticalAlign.new(value: "superscript")
        when "sub"
          props.vertical_align = Uniword::Properties::VerticalAlign.new(value: "subscript")
        when "span"
          apply_span_formatting(element, props)
        end

        # Recursively collect formatting from child elements
        # This handles nested formatting like <u><em><strong>text</strong></em></u>
        element.children.each do |child|
          next unless child.element?

          child_props = collect_formatting_from_element(child)
          merge_run_properties(props, child_props)
        end

        props
      end

      # Merge formatting properties from child into parent
      #
      # @param parent [Uniword::Wordprocessingml::RunProperties] Parent properties
      # @param child [Uniword::Wordprocessingml::RunProperties] Child properties to merge
      def self.merge_run_properties(parent, child)
        parent.bold = child.bold if child.bold
        parent.italic = child.italic if child.italic
        parent.underline = child.underline if child.underline
        parent.strike = child.strike if child.strike
        parent.vertical_align = child.vertical_align if child.vertical_align
        parent.color = child.color if child.color
        parent.size = child.size if child.size
        parent.font = child.font if child.font
      end

      # Apply formatting from span element's style attribute
      #
      # @param element [Nokogiri::XML::Element] span element
      # @param props [Uniword::Wordprocessingml::RunProperties] run properties
      def self.apply_span_formatting(element, props)
        style = element.attr("style") || ""

        # Color
        props.color = Uniword::Properties::ColorValue.new(value: Regexp.last_match(1)) if style =~ /color:\s*#?([0-9a-fA-F]{6})/i

        # Font size
        if style =~ /font-size:\s*([0-9.]+)(pt|px|em)/i
          size = Regexp.last_match(1).to_f
          unit = Regexp.last_match(2)
          # Convert to half-points (OOXML unit)
          half_pts = case unit
                     when "pt" then (size * 2).round
                     when "px" then (size * 2 * 72 / 96).round # 96 DPI assumption
                     when "em" then (size * 24).round # em relative to 12pt base
                     else size.round
                     end
          props.size = Uniword::Properties::FontSize.new(value: half_pts.to_s)
        end

        # Font family
        return unless style =~ /font-family:\s*['"]([^'"]+)['"]/i

        font = Regexp.last_match(1).split(",").first.strip
        props.font = Uniword::Properties::RunFonts.new(ascii: font)
      end

      # Decode standard HTML entities in text.
      # Converts entity names like &copy; to their actual characters.
      # Unknown entities are preserved as-is.
      #
      # @param text [String] Text that may contain HTML entities
      # @return [String] Text with entities decoded
      def self.decode_html_entities(text)
        return text unless text.include?("&")

        # Standard HTML entities that we decode
        entities = {
          "nbsp" => [160].pack("U"),
          "copy" => [169].pack("U"),
          "reg" => [174].pack("U"),
          "trade" => [8482].pack("U"),
          "amp" => "&", # &amp; -> & (already unescaped by Nokogiri, but handle just in case)
          "lt" => "<",
          "gt" => ">",
          "quot" => '"',
          "apos" => "'",
          "ndash" => [8211].pack("U"),
          "mdash" => [8212].pack("U"),
          "lsquo" => [8216].pack("U"),
          "rsquo" => [8217].pack("U"),
          "ldquo" => [8220].pack("U"),
          "rdquo" => [8221].pack("U"),
          "hellip" => [8230].pack("U"),
          "bull" => [8226].pack("U"),
          "mu" => [181].pack("U"), # micro sign
          "plusmn" => [177].pack("U"), # plus-minus
          "times" => [215].pack("U"), # multiplication
          "divide" => [247].pack("U"), # division
          "euro" => [8364].pack("U"),
          "pound" => [163].pack("U"),
          "yen" => [165].pack("U"),
          "cent" => [162].pack("U")
        }

        text.gsub(/&(\w+);/) do
          key = Regexp.last_match(1)
          if entities.key?(key)
            entities[key]
          else
            "&#{key};" # Preserve unknown entity
          end
        end
      end

      # Create a simple run without properties
      #
      # @param text [String] Run text
      # @return [Uniword::Wordprocessingml::Run] OOXML run
      def self.create_run(text)
        # Decode HTML entities in text (e.g., &copy; -> ©)
        decoded_text = decode_html_entities(text)

        run = Uniword::Wordprocessingml::Run.new
        run.text = decoded_text
        run
      end

      # Check if run properties object has any formatting
      #
      # @param props [Uniword::Wordprocessingml::RunProperties] run properties
      # @return [Boolean] true if has formatting
      def self.has_properties?(props)
        props.bold || props.italic || props.underline || props.strike ||
          props.color || props.size || props.font || props.vertical_align
      end

      # Extract body content from HTML document
      #
      # @param html [String] HTML content
      # @return [String] Body content or full content if no body tag
      def self.extract_body(html)
        if html =~ %r{<body[^>]*>(.*?)</body>}im
          Regexp.last_match(1)
        else
          html
        end
      end
    end
  end
end
