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

        doc.css('p, h1, h2, h3, h4, h5, h6, li, div, tr').each do |element|
          next if element.ancestors('table').any? && (element.name == 'tr' || element.name == 'td')
          next if element.ancestors('table').any? && element.name == 'td'

          # Skip container elements (div, li) that have children matching the same selector.
          # This prevents duplicate processing when a div contains a p, since the p's
          # content is more semantically meaningful and the div's text would duplicate it.
          if %w[div li].include?(element.name) && element.css('p, h1, h2, h3, h4, h5, h6, li, div, tr').any?
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

        doc.css('table').each do |html_table|
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

        html_table.css('tr').each do |html_row|
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

        html_row.css('td, th').each do |html_cell|
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
        css_class = html_cell.attr('class')
        if css_class && !css_class.empty?
          mapped_style = map_css_class_to_style(css_class)
          # Style mapping available if needed for cell-level styling
        end

        # Convert cell content to paragraphs
        html_cell.css('p, div, h1, h2, h3, h4, h5, h6').each do |para_element|
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
        css_class = element.attr('class')
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
            run = create_run_from_element(child)
            paragraph.runs << run if run
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
          'MsoTitle' => 'Title',
          'MsoTitle2' => 'Title2',
          'MsoSubtitle' => 'Subtitle',
          'MsoHeading1' => 'Heading1',
          'MsoHeading2' => 'Heading2',
          'MsoHeading3' => 'Heading3',
          'MsoHeading4' => 'Heading4',
          'MsoHeading5' => 'Heading5',
          'MsoHeading6' => 'Heading6',
          'MsoToc1' => 'TOC1',
          'MsoToc2' => 'TOC2',
          'MsoToc3' => 'TOC3',
          'MsoToc4' => 'TOC4',
          'MsoToc5' => 'TOC5',
          'MsoToc6' => 'TOC6',
          'MsoToc7' => 'TOC7',
          'MsoToc8' => 'TOC8',
          'MsoToc9' => 'TOC9',
          'MsoTocHeading' => 'TOC Heading',
          'MsoBibliography' => 'Bibliography',
          'MsoNoSpacing' => 'No Spacing',
          'SectionTitle' => 'SectionTitle',
          'Heading4Char' => 'Heading4Char',
          'Title' => 'Title',  # Direct class match
          'Heading1' => 'Heading1',
          'Heading2' => 'Heading2',
          'Heading3' => 'Heading3',
        }

        # Check each class in the class string
        css_class.split.each do |cls|
          if class_mapping.key?(cls)
            return class_mapping[cls]
          end
        end

        nil
      end

      # Create OOXML run from HTML element with inline formatting
      #
      # @param element [Nokogiri::XML::Element] HTML element
      # @return [Uniword::Wordprocessingml::Run] OOXML run
      def self.create_run_from_element(element)
        text = element.text.strip
        return nil if text.empty?

        # Recursively collect formatting from nested elements
        props = collect_formatting_from_element(element)

        run = Uniword::Wordprocessingml::Run.new
        run.text = text
        run.properties = props if has_properties?(props)
        run
      end

      # Recursively collect formatting properties from element and its children
      #
      # @param element [Nokogiri::XML::Element] HTML element
      # @return [Uniword::Wordprocessingml::RunProperties] Run properties with all formatting
      def self.collect_formatting_from_element(element)
        props = Uniword::Wordprocessingml::RunProperties.new

        case element.name.downcase
        when 'strong', 'b'
          props.bold = Uniword::Properties::Bold.new
        when 'em', 'i'
          props.italic = Uniword::Properties::Italic.new
        when 'u'
          props.underline = Uniword::Properties::Underline.new
        when 's', 'strike'
          props.strike = Uniword::Properties::Strike.new
        when 'sup'
          props.vertical_align = Uniword::Properties::VerticalAlign.new(value: 'superscript')
        when 'sub'
          props.vertical_align = Uniword::Properties::VerticalAlign.new(value: 'subscript')
        when 'span'
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
        style = element.attr('style') || ''

        # Color
        if style =~ /color:\s*#?([0-9a-fA-F]{6})/i
          props.color = Uniword::Properties::ColorValue.new(value: Regexp.last_match(1))
        end

        # Font size
        if style =~ /font-size:\s*([0-9.]+)(pt|px|em)/i
          size = Regexp.last_match(1).to_f
          unit = Regexp.last_match(2)
          # Convert to half-points (OOXML unit)
          half_pts = case unit
                     when 'pt' then (size * 2).round
                     when 'px' then (size * 2 * 72 / 96).round # 96 DPI assumption
                     when 'em' then (size * 24).round # em relative to 12pt base
                     else size.round
                     end
          props.size = Uniword::Properties::FontSize.new(value: half_pts.to_s)
        end

        # Font family
        if style =~ /font-family:\s*['"]([^'"]+)['"]/i
          font = Regexp.last_match(1).split(',').first.strip
          props.font = Uniword::Properties::RunFonts.new(ascii: font)
        end
      end

      # Create a simple run without properties
      #
      # @param text [String] Run text
      # @return [Uniword::Wordprocessingml::Run] OOXML run
      def self.create_run(text)
        run = Uniword::Wordprocessingml::Run.new
        run.text = text
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
        if html =~ /<body[^>]*>(.*?)<\/body>/im
          Regexp.last_match(1)
        else
          html
        end
      end
    end
  end
end
