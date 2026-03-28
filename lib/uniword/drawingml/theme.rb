# frozen_string_literal: true

module Uniword
  module Drawingml
    # Container for theme elements (color scheme, font scheme, format scheme)
    # XML Namespace: a: (DrawingML)
    class ThemeElements < Lutaml::Model::Serializable
      # Color scheme
      attribute :clr_scheme, ColorScheme

      # Font scheme
      attribute :font_scheme, FontScheme

      # Format scheme
      attribute :fmt_scheme, FormatScheme

      # XML configuration
      xml do
        element 'themeElements'
        namespace Ooxml::Namespaces::DrawingML

        map_element 'clrScheme', to: :clr_scheme
        map_element 'fontScheme', to: :font_scheme
        map_element 'fmtScheme', to: :fmt_scheme
      end

      def initialize(attributes = {})
        super
        @clr_scheme ||= ColorScheme.new
        @font_scheme ||= FontScheme.new
        @fmt_scheme ||= FormatScheme.new
      end
    end

    # Represents a document theme containing color and font schemes.
    #
    # Themes provide a consistent set of colors, fonts, and effects
    # that can be applied throughout a document.
    #
    # @example Create a custom theme
    #   theme = Uniword::Drawingml::Theme.new(name: 'Corporate')
    #   theme.color_scheme.colors[:accent1] = '0066CC'
    #   theme.font_scheme.major_font = 'Helvetica'
    #
    # @example Apply theme to document
    #   doc = Uniword::Document.new
    #   doc.theme = theme
    #
    # NOTE: Convenience alias Uniword::Theme is available via lib/uniword.rb
    class Theme < Lutaml::Model::Serializable
      # Theme name
      attribute :name, :string, default: -> { 'Office Theme' }

      # Theme elements container
      attribute :theme_elements, ThemeElements

      # Object defaults (usually empty)
      attribute :object_defaults, ObjectDefaults

      # Extra color scheme list (usually empty)
      attribute :extra_clr_scheme_lst, ExtraColorSchemeList

      # Extension list (may contain theme family info)
      attribute :ext_lst, ExtensionList

      # OOXML namespace configuration
      xml do
        element "theme"
        # Theme element is in DrawingML namespace
        namespace Ooxml::Namespaces::DrawingML

        map_attribute 'name', to: :name
        map_element 'themeElements', to: :theme_elements
        map_element 'objectDefaults', to: :object_defaults
        map_element 'extraClrSchemeLst', to: :extra_clr_scheme_lst
        map_element 'extLst', to: :ext_lst
      end

      # Theme variants (Hash of variant_id => ThemeVariant)
      attr_accessor :variants

      # Source .thmx file path (for reference)
      attr_accessor :source_file

      # Media files associated with theme (images, etc.)
      # Hash of filename => MediaFile objects
      attr_accessor :media_files

      # Raw XML for perfect round-trip preservation
      # Used when theme structure can't be fully modeled yet
      attr_accessor :raw_xml

      # Initialize theme
      #
      # @param attributes [Hash] Theme attributes
      def initialize(attributes = {})
        super
        @theme_elements ||= ThemeElements.new
        @object_defaults ||= ObjectDefaults.new
        @extra_clr_scheme_lst ||= ExtraColorSchemeList.new
        @ext_lst ||= ExtensionList.new
        @variants = {}
        @source_file = nil
        @media_files ||= {}
      end

      # Get color scheme (compatibility accessor)
      def color_scheme
        @theme_elements&.clr_scheme
      end

      # Set color scheme (compatibility accessor)
      def color_scheme=(scheme)
        @theme_elements ||= ThemeElements.new
        @theme_elements.clr_scheme = scheme
      end

      # Get font scheme (compatibility accessor)
      def font_scheme
        @theme_elements&.font_scheme
      end

      # Set font scheme (compatibility accessor)
      def font_scheme=(scheme)
        @theme_elements ||= ThemeElements.new
        @theme_elements.font_scheme = scheme
      end

      # Duplicate the theme
      #
      # @return [Theme] A deep copy of this theme
      def dup
        new_theme = Theme.new(name: name)
        new_theme.color_scheme = color_scheme.dup if color_scheme
        new_theme.font_scheme = font_scheme.dup if font_scheme
        new_theme.variants = @variants.dup if @variants
        new_theme.source_file = @source_file
        new_theme
      end

      # Check if theme is valid
      #
      # @return [Boolean] true if valid
      def valid?
        !name.nil? && !name.empty?
      end

      # Get a theme color by name
      #
      # @param color_name [String, Symbol] The color name
      # @return [String, nil] The RGB hex color value
      def color(color_name)
        color_scheme&.[](color_name)
      end

      # Get the major font (for headings)
      #
      # @return [String, nil] The major font name
      def major_font
        font_scheme&.major_font
      end

      # Get the minor font (for body text)
      #
      # @return [String, nil] The minor font name
      def minor_font
        font_scheme&.minor_font
      end

      # Provide detailed inspection for debugging
      #
      # @return [String] A readable representation of the theme
      def inspect
        "#<Uniword::Drawingml::Theme name=#{name.inspect} " \
          "colors=#{@color_scheme&.colors&.count || 0} " \
          "major_font=#{major_font.inspect} " \
          "minor_font=#{minor_font.inspect} " \
          "variants=#{@variants&.keys&.count || 0}>"
      end

      # Load theme from .thmx file
      #
      # @param path [String] Path to .thmx file
      # @param variant [String, Integer, nil] Optional variant to apply
      # @return [Theme] Loaded theme
      #
      # @example Load theme
      #   theme = Theme.from_thmx('Atlas.thmx')
      #
      # @example Load with variant
      #   theme = Theme.from_thmx('Atlas.thmx', variant: 2)
      def self.from_thmx(path, variant: nil)
        loader = Uniword::Themes::ThemeLoader.new
        if variant
          loader.load_with_variant(path, variant)
        else
          loader.load(path)
        end
      end

      # Apply this theme to a document
      #
      # @param document [Document] Target document
      # @return [void]
      def apply_to(document)
        applicator = Uniword::Themes::ThemeApplicator.new
        applicator.apply(self, document)
      end
    end
  end
end
