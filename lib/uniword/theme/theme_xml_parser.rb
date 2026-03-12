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


        theme = ::Uniword::Theme.new
        theme.name = theme_node['name'] || 'Untitled Theme'

        # Create theme_elements if not exists
        theme.theme_elements ||= ::Uniword::ThemeElements.new

        # Parse color scheme
        color_scheme_node = doc.at_xpath('//a:themeElements/a:clrScheme', THEME_NS)
        if color_scheme_node
          scheme = parse_color_scheme(color_scheme_node)
          theme.theme_elements.clr_scheme = scheme
        end

        # Parse font scheme
        font_scheme_node = doc.at_xpath('//a:themeElements/a:fontScheme', THEME_NS)
        if font_scheme_node
          scheme = parse_font_scheme(font_scheme_node)
          theme.theme_elements.font_scheme = scheme
        end

        theme
      end

      private

      # Parse color scheme from XML
      #
      # @param node [Nokogiri::XML::Element] Color scheme node
      # @return [ColorScheme] Parsed color scheme
      def parse_color_scheme(node)

        scheme = ColorScheme.new
        scheme.name = node['name'] || 'Color Scheme'

        # Parse each of the 12 standard theme colors
        ColorScheme::THEME_COLORS.each do |color_name|
          color_node = node.at_xpath("a:#{color_name}", THEME_NS)
          next unless color_node

          # Extract color information
          color_obj = extract_color_object(color_node, color_name)

          # Set the color using the appropriate attribute
          attr_name = color_name == 'folHlink' ? :fol_hlink : color_name.to_sym
          scheme.instance_variable_set("@#{attr_name}", color_obj)
        end

        # Sync hash interface
        scheme.sync_colors_hash

        scheme
      end

      # Extract color object with proper class
      def extract_color_object(node, color_name)
        # Determine the color class
        color_class = case color_name
                      when 'dk1' then Uniword::Dk1Color
                      when 'lt1' then Uniword::Lt1Color
                      when 'dk2' then Uniword::Dk2Color
                      when 'lt2' then Uniword::Lt2Color
                      when 'accent1' then Uniword::Accent1Color
                      when 'accent2' then Uniword::Accent2Color
                      when 'accent3' then Uniword::Accent3Color
                      when 'accent4' then Uniword::Accent4Color
                      when 'accent5' then Uniword::Accent5Color
                      when 'accent6' then Uniword::Accent6Color
                      when 'hlink' then Uniword::HlinkColor
                      when 'folHlink' then Uniword::FolHlinkColor
                      else Uniword::Dk1Color
                      end

        # Check for srgbClr first
        srgb_node = node.at_xpath('.//a:srgbClr', THEME_NS)
        if srgb_node
          color_obj = color_class.new
          color_obj.srgb_clr = Uniword::SrgbColor.new(val: srgb_node['val'])
          color_obj.sys_clr = nil # Explicitly clear sys_clr
          return color_obj
        end

        # Check for sysClr
        sys_node = node.at_xpath('.//a:sysClr', THEME_NS)
        if sys_node
          color_obj = color_class.new
          color_obj.sys_clr = Uniword::SysColor.new(
            val: sys_node['val'],
            last_clr: sys_node['lastClr']
          )
          color_obj.srgb_clr = nil # Explicitly clear srgb_clr
          return color_obj
        end

        # Default - create with srgbClr
        color_class.new
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
        return convert_preset_color(prst_node['val']) if prst_node

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

        scheme = FontScheme.new
        scheme.name = node['name'] || 'Font Scheme'

        # Parse major font
        major_font_node = node.at_xpath('a:majorFont', THEME_NS)
        scheme.major_font_obj = parse_font_container(major_font_node, :major) if major_font_node

        # Parse minor font
        minor_font_node = node.at_xpath('a:minorFont', THEME_NS)
        scheme.minor_font_obj = parse_font_container(minor_font_node, :minor) if minor_font_node

        scheme
      end

      # Parse major or minor font container
      def parse_font_container(node, type)

        container = type == :major ? Uniword::MajorFont.new : Uniword::MinorFont.new

        # Parse latin font
        latin_node = node.at_xpath('a:latin', THEME_NS)
        if latin_node
          container.latin = Uniword::LatinFont.new(
            typeface: latin_node['typeface'] || '',
            panose: latin_node['panose']
          )
        end

        # Parse ea font
        ea_node = node.at_xpath('a:ea', THEME_NS)
        if ea_node
          container.ea = Uniword::EaFont.new(
            typeface: ea_node['typeface'] || ''
          )
        end

        # Parse cs font
        cs_node = node.at_xpath('a:cs', THEME_NS)
        if cs_node
          container.cs = Uniword::CsFont.new(
            typeface: cs_node['typeface'] || ''
          )
        end

        # Parse script-specific fonts
        font_nodes = node.xpath('a:font', THEME_NS)
        container.fonts = font_nodes.map do |font_node|
          Uniword::ScriptFont.new(
            script: font_node['script'] || '',
            typeface: font_node['typeface'] || ''
          )
        end

        container
      end
    end
  end
end
