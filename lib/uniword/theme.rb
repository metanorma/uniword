# frozen_string_literal: true

require_relative 'color_scheme'
require_relative 'font_scheme'
require_relative 'format_scheme'
require_relative 'object_defaults'
require_relative 'extra_color_scheme_list'
require_relative 'extension_list'

module Uniword
  # Container for theme elements (color scheme, font scheme, format scheme)
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
  #   theme = Uniword::Theme.new(name: 'Corporate')
  #   theme.color_scheme.colors[:accent1] = '0066CC'
  #   theme.font_scheme.major_font = 'Helvetica'
  #
  # @example Apply theme to document
  #   doc = Uniword::Document.new
  #   doc.theme = theme
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
      root 'theme'
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
      new_theme.color_scheme = @color_scheme.dup if @color_scheme
      new_theme.font_scheme = @font_scheme.dup if @font_scheme
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
      @color_scheme&.[](color_name)
    end

    # Get the major font (for headings)
    #
    # @return [String, nil] The major font name
    def major_font
      @font_scheme&.major_font
    end

    # Get the minor font (for body text)
    #
    # @return [String, nil] The minor font name
    def minor_font
      @font_scheme&.minor_font
    end

    # Provide detailed inspection for debugging
    #
    # @return [String] A readable representation of the theme
    def inspect
      "#<Uniword::Theme name=#{name.inspect} " \
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
      require_relative 'theme/theme_loader'

      loader = Themes::ThemeLoader.new
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
      require_relative 'theme/theme_applicator'

      applicator = Themes::ThemeApplicator.new
      applicator.apply(self, document)
    end

    # Load theme from YAML file
    #
    # @param path [String] Path to YAML file
    # @param variant [String, Integer, nil] Optional variant
    # @return [Theme] Loaded theme
    #
    # @example Load from YAML
    #   theme = Theme.from_yaml('custom_theme.yml')
    #   theme = Theme.from_yaml('custom_theme.yml', variant: 2)
    def self.from_yaml(path, variant: nil)
      require_relative 'themes/yaml_theme_loader'

      loader = Themes::YamlThemeLoader.new
      loader.load(path, variant: variant)
    end

    # Load bundled theme by name
    #
    # @param name [String] Theme name (e.g., 'atlas', 'office_theme')
    # @param variant [String, Integer, nil] Optional variant
    # @return [Theme] Loaded theme
    #
    # @example Load bundled theme
    #   theme = Theme.load('atlas')
    #   theme = Theme.load('atlas', variant: 2)
    def self.load(name, variant: nil)
      require_relative 'themes/yaml_theme_loader'

      Themes::YamlThemeLoader.load_bundled(name, variant: variant)
    end

    # List all available bundled themes
    #
    # @return [Array<String>] Theme names
    #
    # @example List themes
    #   themes = Theme.available_themes
    #   # => ["atlas", "badge", "berlin", ...]
    def self.available_themes
      require_relative 'themes/yaml_theme_loader'

      Themes::YamlThemeLoader.available_themes
    end
  end
end
