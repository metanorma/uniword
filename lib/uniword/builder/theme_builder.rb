# frozen_string_literal: true

module Uniword
  module Builder
    # Builds and applies themes to documents.
    #
    # Themes control the overall look of a document through color schemes,
    # font schemes, and format schemes.
    #
    # @example Apply a bundled theme
    #   doc.theme('atlas')
    #
    # @example Apply and customize a theme
    #   doc.theme('office') do |t|
    #     t.colors(accent1: 'FF0000', accent2: '00FF00')
    #     t.fonts(major: 'Georgia', minor: 'Calibri')
    #   end
    class ThemeBuilder
      def initialize(document)
        @document = document
      end

      # Apply a named bundled theme
      #
      # Bundled themes are YAML files in data/themes/.
      # Available themes: Themes::Theme.available_themes
      #
      # @param name [String] Theme name (e.g., 'atlas', 'badge', 'office')
      # @return [self]
      def apply(name)
        friendly = Themes::Theme.load(name)
        @document.model.theme =
          Themes::ThemeTransformation.new.to_word(friendly)
        self
      end

      # Apply a theme from a .thmx file
      #
      # @param path [String] Path to .thmx theme file
      # @param variant [String, nil] Theme variant
      # @return [self]
      def apply_file(path, variant: nil)
        @document.model.theme =
          Drawingml::Theme.from_thmx(path, variant: variant)
        self
      end

      # Override theme colors
      #
      # @param overrides [Hash] Color slot overrides (e.g., accent1: 'FF0000')
      # @return [self]
      def colors(**overrides)
        theme = @document.model.theme
        return self unless theme

        scheme = theme.theme_elements&.clr_scheme
        return self unless scheme

        overrides.each do |slot, color|
          scheme[slot.to_sym] = color
        end
        self
      end

      # Override theme fonts
      #
      # @param major [String, nil] Major font (headings)
      # @param minor [String, nil] Minor font (body)
      # @return [self]
      def fonts(major: nil, minor: nil)
        theme = @document.model.theme
        return self unless theme

        fs = theme.theme_elements&.font_scheme
        return self unless fs

        fs.major_font = major if major
        fs.minor_font = minor if minor
        self
      end

      # Get a theme color value
      #
      # @param slot [Symbol, String] Color slot (e.g., :accent1, :dk1)
      # @return [String, nil] Hex color value
      def color(slot)
        @document.model.theme&.color(slot.to_sym)
      end

      # List available bundled themes
      #
      # @return [Array<String>] Theme names
      def available
        Themes::Theme.available_themes
      end
    end
  end
end
