# frozen_string_literal: true

module Uniword
  module Transformation
    # Maps HTML formatting (CSS classes, inline styles, inline elements)
    # to OOXML run properties.
    #
    # Pure functions — no state, no side effects.
    # Used by HtmlElementBuilder when constructing OOXML runs.
    #
    # Responsibilities:
    # - CSS class → OOXML style name mapping
    # - Inline style property extraction (color, font-size, font-family)
    # - HTML inline element → OOXML formatting (bold, italic, underline, etc.)
    # - HTML entity decoding
    class HtmlFormattingMapper
      # Map MHT CSS class to OOXML style name.
      #
      # @param css_class [String] CSS class string (may contain multiple classes)
      # @return [String, nil] OOXML style name or nil
      def self.map_css_class_to_style(css_class)
        css_class.split.each do |cls|
          return CSS_CLASS_MAPPING[cls] if CSS_CLASS_MAPPING.key?(cls)
        end

        nil
      end

      # Recursively collect formatting properties from element and its children.
      #
      # Handles nested formatting like <u><em><strong>text</strong></em></u>.
      #
      # @param element [Nokogiri::XML::Element] HTML element
      # @return [Uniword::Wordprocessingml::RunProperties]
      def self.collect_formatting(element)
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
          props.vertical_align =
            Uniword::Properties::VerticalAlign.new(value: "superscript")
        when "sub"
          props.vertical_align =
            Uniword::Properties::VerticalAlign.new(value: "subscript")
        when "span"
          apply_span_styles(element, props)
        end

        element.children.each do |child|
          next unless child.element?

          child_props = collect_formatting(child)
          merge_properties(props, child_props)
        end

        props
      end

      # Merge formatting from child into parent.
      #
      # @param parent [Uniword::Wordprocessingml::RunProperties]
      # @param child [Uniword::Wordprocessingml::RunProperties]
      def self.merge_properties(parent, child)
        parent.bold = child.bold if child.bold
        parent.italic = child.italic if child.italic
        parent.underline = child.underline if child.underline
        parent.strike = child.strike if child.strike
        parent.vertical_align = child.vertical_align if child.vertical_align
        parent.color = child.color if child.color
        parent.size = child.size if child.size
        parent.font = child.font if child.font
      end

      # Check if run properties have any formatting set.
      #
      # @param props [Uniword::Wordprocessingml::RunProperties]
      # @return [Boolean]
      def self.has_formatting?(props)
        props.bold || props.italic || props.underline || props.strike ||
          props.color || props.size || props.font || props.vertical_align
      end

      # Decode standard HTML entities in text.
      #
      # Converts entity names like &copy; to their actual characters.
      # Unknown entities are preserved as-is.
      #
      # @param text [String] Text that may contain HTML entities
      # @return [String] Text with entities decoded
      def self.decode_entities(text)
        return text unless text.include?("&")

        text.gsub(/&(\w+);/) do
          key = Regexp.last_match(1)
          HTML_ENTITIES.key?(key) ? HTML_ENTITIES[key] : "&#{key};"
        end
      end

      # Extract body content from full HTML document.
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

      # Apply formatting from span element's style attribute.
      #
      # @param element [Nokogiri::XML::Element] span element
      # @param props [Uniword::Wordprocessingml::RunProperties]
      def self.apply_span_styles(element, props)
        style = element.attr("style") || ""

        if style =~ /color:\s*#?([0-9a-fA-F]{6})/i
          props.color =
            Uniword::Properties::ColorValue.new(value: Regexp.last_match(1))
        end

        if style =~ /font-size:\s*([0-9.]+)(pt|px|em)/i
          size = Regexp.last_match(1).to_f
          unit = Regexp.last_match(2)
          half_pts = size_in_half_points(size, unit)
          props.size = Uniword::Properties::FontSize.new(value: half_pts.to_s)
        end

        return unless style =~ /font-family:\s*['"]([^'"]+)['"]/i

        font = Regexp.last_match(1).split(",").first.strip
        props.font = Uniword::Properties::RunFonts.new(ascii: font)
      end

      # Convert font size to half-points (OOXML unit).
      #
      # @param size [Float] Size value
      # @param unit [String] Unit ("pt", "px", or "em")
      # @return [Integer] Size in half-points
      def self.size_in_half_points(size, unit)
        case unit
        when "pt" then (size * 2).round
        when "px" then (size * 2 * 72 / 96).round
        when "em" then (size * 24).round
        else size.round
        end
      end

      # CSS class → OOXML style mapping for MHT documents
      CSS_CLASS_MAPPING = {
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
      }.freeze

      # Standard HTML entities
      HTML_ENTITIES = {
        "nbsp" => [160].pack("U"),
        "copy" => [169].pack("U"),
        "reg" => [174].pack("U"),
        "trade" => [8482].pack("U"),
        "amp" => "&",
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
        "mu" => [181].pack("U"),
        "plusmn" => [177].pack("U"),
        "times" => [215].pack("U"),
        "divide" => [247].pack("U"),
        "euro" => [8364].pack("U"),
        "pound" => [163].pack("U"),
        "yen" => [165].pack("U"),
        "cent" => [162].pack("U")
      }.freeze
    end
  end
end
