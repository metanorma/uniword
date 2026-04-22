# frozen_string_literal: true

module Uniword
  module Transformation
    # SERVICE for converting HTML to OOXML elements.
    #
    # Public API coordinator — delegates to HtmlElementBuilder for
    # OOXML construction and HtmlFormattingMapper for CSS/style handling.
    #
    # Pure functions — no state, no side effects.
    # Used by Transformer when source_format is :mhtml.
    class HtmlToOoxmlConverter
      # Convert HTML content to OOXML paragraphs.
      #
      # @param html_content [String] HTML content (may include full HTML document)
      # @return [Array<Uniword::Wordprocessingml::Paragraph>]
      def self.html_to_paragraphs(html_content)
        return [] if html_content.nil? || html_content.empty?

        body = HtmlFormattingMapper.extract_body(html_content)
        doc = Nokogiri::HTML(body)
        paragraphs = []

        doc.css("p, h1, h2, h3, h4, h5, h6, li, div, tr").each do |element|
          next if element.ancestors("td, th").any?
          next if %w[tr td].include?(element.name)

          if %w[div li].include?(element.name) &&
             element.css("p, h1, h2, h3, h4, h5, h6, li, div, tr").any?
            next
          end

          paragraph = HtmlElementBuilder.build_paragraph(element)
          paragraphs << paragraph if paragraph
        end

        paragraphs
      end

      # Convert HTML content to OOXML tables.
      #
      # @param html_content [String] HTML content (may include full HTML document)
      # @return [Array<Uniword::Wordprocessingml::Table>]
      def self.html_to_tables(html_content)
        return [] if html_content.nil? || html_content.empty?

        body = HtmlFormattingMapper.extract_body(html_content)
        doc = Nokogiri::HTML(body)
        tables = []

        doc.css("table").each do |html_table|
          table = HtmlElementBuilder.build_table(html_table)
          tables << table if table
        end

        tables
      end

      # Convert a single HTML table to OOXML table.
      #
      # @param html_table [Nokogiri::XML::Element] HTML table element
      # @return [Uniword::Wordprocessingml::Table, nil]
      def self.html_table_to_table(html_table)
        HtmlElementBuilder.build_table(html_table)
      end

      # Convert a single HTML row to OOXML table row.
      #
      # @param html_row [Nokogiri::XML::Element] HTML tr element
      # @return [Uniword::Wordprocessingml::TableRow, nil]
      def self.html_row_to_row(html_row)
        HtmlElementBuilder.build_row(html_row)
      end

      # Convert a single HTML cell to OOXML table cell.
      #
      # @param html_cell [Nokogiri::XML::Element] HTML td/th element
      # @return [Uniword::Wordprocessingml::TableCell, nil]
      def self.html_cell_to_cell(html_cell)
        HtmlElementBuilder.build_cell(html_cell)
      end

      # Convert a single HTML element to OOXML paragraph.
      #
      # @param element [Nokogiri::XML::Element] HTML element
      # @return [Uniword::Wordprocessingml::Paragraph, nil]
      def self.html_element_to_paragraph(element)
        HtmlElementBuilder.build_paragraph(element)
      end

      # Map MHT CSS class to OOXML style name.
      #
      # @param css_class [String] CSS class string
      # @return [String, nil]
      def self.map_css_class_to_style(css_class)
        HtmlFormattingMapper.map_css_class_to_style(css_class)
      end

      # Create a run from HTML element with inline formatting.
      #
      # @param element [Nokogiri::XML::Element] HTML element
      # @return [Uniword::Wordprocessingml::Run, nil]
      def self.create_run_from_element(element)
        HtmlElementBuilder.create_run_from_element(element)
      end

      # Create a simple run without properties.
      #
      # @param text [String] Run text
      # @return [Uniword::Wordprocessingml::Run]
      def self.create_run(text)
        HtmlElementBuilder.create_run(text)
      end

      # Decode HTML entities.
      #
      # @param text [String]
      # @return [String]
      def self.decode_html_entities(text)
        HtmlFormattingMapper.decode_entities(text)
      end

      # Extract body content from HTML document.
      #
      # @param html [String]
      # @return [String]
      def self.extract_body(html)
        HtmlFormattingMapper.extract_body(html)
      end
    end
  end
end
