# frozen_string_literal: true

module Uniword
  # Represents a color scheme from a Word document theme.
  #
  # Color schemes define the theme colors used throughout the document.
  # There are 12 standard theme colors in Office Open XML.
  #
  # @example Create a custom color scheme
  #   scheme = Uniword::ColorScheme.new
  #   scheme.colors[:accent1] = '0066CC'  # Corporate blue
  #   scheme.colors[:accent2] = 'FF6600'  # Corporate orange
  class ColorScheme < Lutaml::Model::Serializable
    # OOXML namespace configuration
    xml do
      root 'clrScheme'
      namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

      map_attribute 'name', to: :name
    end

    # The 12 standard theme colors defined in OOXML
    THEME_COLORS = %w[
      dk1 lt1 dk2 lt2
      accent1 accent2 accent3 accent4 accent5 accent6
      hlink folHlink
    ].freeze

    # Color scheme name
    attribute :name, :string, default: -> { 'Office' }

    # Hash mapping color names to RGB hex values
    attr_accessor :colors

    # Initialize color scheme
    #
    # @param attributes [Hash] Color scheme attributes
    def initialize(attributes = {})
      super
      @colors = {}
      initialize_default_colors if @colors.empty?
    end

    # Get a color by name
    #
    # @param color_name [String, Symbol] The color name (e.g., :accent1)
    # @return [String, nil] The RGB hex color value
    def [](color_name)
      @colors[color_name.to_sym]
    end

    # Set a color by name
    #
    # @param color_name [String, Symbol] The color name
    # @param value [String] The RGB hex color value
    def []=(color_name, value)
      @colors[color_name.to_sym] = value
    end

    # Get all defined colors
    #
    # @return [Hash] All colors
    def all_colors
      @colors
    end

    # Check if color scheme has a specific color defined
    #
    # @param color_name [String, Symbol] The color name
    # @return [Boolean] true if color is defined
    def has_color?(color_name)
      @colors.key?(color_name.to_sym)
    end

    # Duplicate the color scheme
    #
    # @return [ColorScheme] A deep copy of this color scheme
    def dup
      new_scheme = ColorScheme.new(name: name)
      new_scheme.colors = @colors.dup
      new_scheme
    end

    private

    # Initialize with default Office theme colors
    def initialize_default_colors
      @colors = {
        dk1: '000000',      # Dark 1 (Black)
        lt1: 'FFFFFF',      # Light 1 (White)
        dk2: '44546A',      # Dark 2 (Dark Blue)
        lt2: 'E7E6E6',      # Light 2 (Light Gray)
        accent1: '4472C4',  # Accent 1 (Blue)
        accent2: 'ED7D31',  # Accent 2 (Orange)
        accent3: 'A5A5A5',  # Accent 3 (Gray)
        accent4: 'FFC000',  # Accent 4 (Yellow)
        accent5: '5B9BD5',  # Accent 5 (Light Blue)
        accent6: '70AD47',  # Accent 6 (Green)
        hlink: '0563C1',    # Hyperlink (Dark Blue)
        folHlink: '954F72'  # Followed Hyperlink (Purple)
      }
    end
  end
end