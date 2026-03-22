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

        doc.css('p, h1, h2, h3, h4, h5, h6, li, div, tr, td').each do |element|
          next if element.ancestors('table').any? && element.name == 'td'
          next if element.ancestors('tr').any? && element.name == 'td'

          paragraph = html_element_to_paragraph(element)
          paragraphs << paragraph if paragraph
        end

        paragraphs
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

      # Create OOXML run from HTML element with inline formatting
      #
      # @param element [Nokogiri::XML::Element] HTML element
      # @return [Uniword::Wordprocessingml::Run] OOXML run
      def self.create_run_from_element(element)
        text = element.text.strip
        return nil if text.empty?

        run = Uniword::Wordprocessingml::Run.new
        run.text = text

        # Apply inline formatting
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
        when 'span'
          apply_span_formatting(element, props)
        when 'sup'
          props.vertical_align = Uniword::Properties::VerticalAlign.new(value: 'superscript')
        when 'sub'
          props.vertical_align = Uniword::Properties::VerticalAlign.new(value: 'subscript')
        when 'br'
          run.text = "\n"
          return run
        end

        run.properties = props if has_properties?(props)
        run
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
