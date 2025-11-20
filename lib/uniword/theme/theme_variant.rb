# frozen_string_literal: true

module Uniword
  module Themes
    # Represents a theme variant
    #
    # Theme variants provide visual style variations of a base theme.
    # In .thmx files, variants are numbered (variant1, variant2, etc.)
    # and each contains a complete theme definition that can override
    # the base theme's colors, fonts, or effects.
    #
    # @example Create and apply a variant
    #   variant = ThemeVariant.new('variant2')
    #   variant.theme_xml = variant_theme_xml_content
    #   themed = variant.apply_to(base_theme)
    class ThemeVariant
      # @return [String] Variant identifier (e.g., 'variant1', 'variant2')
      attr_accessor :id

      # @return [String, nil] Variant GUID from theme package
      attr_accessor :guid

      # @return [String, nil] Raw theme XML for this variant
      attr_accessor :theme_xml

      # @return [Theme, nil] Parsed theme for this variant
      attr_accessor :theme

      # Initialize a theme variant
      #
      # @param id [String] Variant identifier
      # @param theme_xml [String, nil] Optional variant theme XML
      def initialize(id, theme_xml: nil)
        @id = id
        @theme_xml = theme_xml
        @theme = nil
        @guid = nil
      end

      # Parse the variant theme XML
      #
      # @return [Theme] Parsed variant theme
      def parse_theme
        return @theme if @theme
        return nil unless @theme_xml

        require_relative 'theme_xml_parser'
        parser = ThemeXmlParser.new
        @theme = parser.parse(@theme_xml)
      end

      # Apply this variant to a base theme
      #
      # For now, this simply returns the variant's theme since
      # variants in .thmx files are complete theme definitions.
      # Future enhancement: merge variant with base theme selectively.
      #
      # @param base_theme [Theme] Base theme (unused in current implementation)
      # @return [Theme] Variant theme (or parsed variant theme)
      def apply_to(base_theme)
        # Parse theme if not already parsed
        parse_theme unless @theme

        # Return the variant theme
        # In .thmx files, variants are complete themes, not just overrides
        @theme || base_theme.dup
      end

      # Get a descriptive name for this variant
      #
      # @return [String] Variant name
      def name
        # In the future, this could map to display names
        # For now, just return the ID
        @id
      end

      # Provide detailed inspection for debugging
      #
      # @return [String] A readable representation of the variant
      def inspect
        "#<Uniword::Theme::ThemeVariant id=#{@id.inspect} " \
          "guid=#{@guid.inspect} " \
          "theme=#{@theme ? @theme.name : 'not parsed'}>"
      end
    end
  end
end