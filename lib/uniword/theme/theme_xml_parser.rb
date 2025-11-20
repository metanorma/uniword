# frozen_string_literal: true

require 'nokogiri'

module Uniword
  module Themes
    # Parses theme XML files into Theme models
    #
    # Handles parsing of theme1.xml files from .thmx packages,
    # extracting color schemes, font schemes, and format schemes.
    #
    # @example Parse a theme XML file
    #   parser = ThemeXmlParser.new
    #   theme = parser.parse(theme_xml_content)
    #   puts theme.name
    #   puts theme.color_scheme.colors[:accent1]
    class ThemeXmlParser
      # DrawingML namespace used in theme XML
      THEME_NS = {
        'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main'
      }.freeze

      # Parse theme1.xml into Theme model
      #
      # @param xml [String] Theme XML content
      # @return [Theme] Parsed theme
      # @raise [ArgumentError] if XML is invalid or missing theme element
      def parse(xml)
        doc = Nokogiri::XML(xml)
        theme_node = doc.at_xpath('//a:theme', THEME_NS)

        raise ArgumentError, 'Invalid theme XML: missing theme element' unless theme_node

        require_relative '../theme'

        theme = ::Uniword::Theme.new
        theme.name = theme_node['name'] || 'Untitled Theme'

        # Parse color scheme
        color_scheme_node = doc.at_xpath('//a:themeElements/a:clrScheme', THEME_NS)
        theme.color_scheme = parse_color_scheme(color_scheme_node) if color_scheme_node

        # Parse font scheme
        font_scheme_node = doc.at_xpath('//a:themeElements/a:fontScheme', THEME_NS)
        theme.font_scheme = parse_font_scheme(font_scheme_node) if font_scheme_node

        theme
      end

      private

      # Parse color scheme from XML
      #
      # @param node [Nokogiri::XML::Element] Color scheme node
      # @return [ColorScheme] Parsed color scheme
      def parse_color_scheme(node)
        require_relative '../color_scheme'

        scheme = ColorScheme.new
        scheme.name = node['name'] || 'Color Scheme'

        # Parse each of the 12 standard theme colors
        ColorScheme::THEME_COLORS.each do |color_name|
          color_node = node.at_xpath("a:#{color_name}", THEME_NS)
          next unless color_node

          color_value = extract_color_value(color_node)
          scheme[color_name] = color_value if color_value
        end

        scheme
      end

      # Extract color value from color node
      #
      # Handles multiple color representation types:
      # - srgbClr: RGB color (most common)
      # - sysClr: System color with last known value
      # - schemeClr: Reference to another theme color
      # - prstClr: Preset color name
      #
      # @param node [Nokogiri::XML::Element] Color node
      # @return [String, nil] RGB hex value (6 characters, no #)
      def extract_color_value(node)
        # Try sRGB color first (direct RGB value)
        srgb_node = node.at_xpath('.//a:srgbClr', THEME_NS)
        return srgb_node['val'] if srgb_node

        # Try system color (use last known color value)
        sys_node = node.at_xpath('.//a:sysClr', THEME_NS)
        return sys_node['lastClr'] if sys_node

        # Try preset color (named color)
        prst_node = node.at_xpath('.//a:prstClr', THEME_NS)
        if prst_node
          return convert_preset_color(prst_node['val'])
        end

        # Scheme color references would need color resolution
        # For now, return nil and let default colors be used
        nil
      end

      # Convert preset color name to RGB hex
      #
      # @param color_name [String] Preset color name
      # @return [String] RGB hex value
      def convert_preset_color(color_name)
        # Common preset colors - expand as needed
        preset_colors = {
          'black' => '000000',
          'white' => 'FFFFFF',
          'red' => 'FF0000',
          'green' => '00FF00',
          'blue' => '0000FF',
          'yellow' => 'FFFF00',
          'magenta' => 'FF00FF',
          'cyan' => '00FFFF'
        }

        preset_colors[color_name.downcase] || '000000'
      end

      # Parse font scheme from XML
      #
      # @param node [Nokogiri::XML::Element] Font scheme node
      # @return [FontScheme] Parsed font scheme
      def parse_font_scheme(node)
        require_relative '../font_scheme'

        scheme = FontScheme.new
        scheme.name = node['name'] || 'Font Scheme'

        # Parse major font (for headings)
        major_node = node.at_xpath('a:majorFont/a:latin', THEME_NS)
        scheme.major_font = major_node['typeface'] if major_node

        # Parse minor font (for body text)
        minor_node = node.at_xpath('a:minorFont/a:latin', THEME_NS)
        scheme.minor_font = minor_node['typeface'] if minor_node

        # Parse East Asian fonts if present
        major_ea_node = node.at_xpath('a:majorFont/a:ea', THEME_NS)
        scheme.major_east_asian = major_ea_node['typeface'] if major_ea_node && major_ea_node['typeface']

        minor_ea_node = node.at_xpath('a:minorFont/a:ea', THEME_NS)
        scheme.minor_east_asian = minor_ea_node['typeface'] if minor_ea_node && minor_ea_node['typeface']

        # Parse complex script fonts if present
        major_cs_node = node.at_xpath('a:majorFont/a:cs', THEME_NS)
        scheme.major_complex_script = major_cs_node['typeface'] if major_cs_node && major_cs_node['typeface']

        minor_cs_node = node.at_xpath('a:minorFont/a:cs', THEME_NS)
        scheme.minor_complex_script = minor_cs_node['typeface'] if minor_cs_node && minor_cs_node['typeface']

        scheme
      end
    end
  end
end