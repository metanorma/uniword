# frozen_string_literal: true

module Uniword
  module Themes
    # Friendly Color Scheme - simplified color model
    #
    # Represents colors as simple hex values, abstracting away OOXML complexity.
    #
    # @example
    #   scheme = ColorScheme.new(
    #     name: 'Atlas',
    #     colors: {
    #       accent1: 'F81B02',
    #       dk1: '000000',
    #       lt1: 'FFFFFF'
    #     }
    #   )
    class ColorScheme < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :colors, :hash

      yaml do
        map "name", to: :name
        map "colors", to: :colors
      end

      # Key name aliases (maps snake_case to camelCase)
      KEY_ALIASES = {
        fol_hlink: "folHlink"
      }.freeze

      # Convenience accessor for colors hash
      # Handles both snake_case (:fol_hlink) and camelCase ('folHlink') keys
      #
      # @param key [Symbol, String] Color key (:dk1, :lt1, :accent1, etc.)
      # @return [String, nil] Hex color value or nil
      def [](key)
        key_str = key.to_s
        # Try exact match first
        result = colors&.[](key.to_sym) || colors&.[](key_str)
        return result if result

        # Try alias mapping
        if (aliased = KEY_ALIASES[key.to_sym])
          colors&.[](aliased.to_sym) || colors&.[](aliased)
        end
      end

      # Convenience setter for colors hash
      #
      # @param key [Symbol] Color key
      # @param value [String] Hex color value
      def []=(key, value)
        self.colors ||= {}
        colors[key.to_sym] = value
      end
    end

    # Friendly Font Scheme - simplified font model
    #
    # Represents fonts as simple typeface names, abstracting away OOXML complexity.
    #
    # @example
    #   scheme = FontScheme.new(
    #     name: 'Atlas',
    #     major_font: 'Calibri Light',
    #     minor_font: 'Calibri'
    #   )
    class FontScheme < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :major_font, :string
      attribute :minor_font, :string
      attribute :major_east_asian, :string
      attribute :major_complex_script, :string
      attribute :minor_east_asian, :string
      attribute :minor_complex_script, :string
      attribute :per_script, :hash

      yaml do
        map "name", to: :name
        map "major_font", to: :major_font
        map "minor_font", to: :minor_font
        map "major_east_asian", to: :major_east_asian
        map "major_complex_script", to: :major_complex_script
        map "minor_east_asian", to: :minor_east_asian
        map "minor_complex_script", to: :minor_complex_script
        map "per_script", to: :per_script
      end
    end

    # Friendly Theme Model - implementation-independent, human-editable
    #
    # This model provides a simplified, human-friendly YAML schema for themes.
    # It is intentionally independent of OOXML structure, making it easy to
    # author and edit by hand.
    #
    # For Word document generation, convert to Drawingml::Theme using
    # ThemeTransformation.to_word_theme(friendly_theme).
    #
    # @example Load from YAML
    #   theme = Theme.from_yaml(File.read('atlas.yml'))
    #
    # @example Convert to Word Theme
    #   transformation = ThemeTransformation.new
    #   word_theme = transformation.to_word(theme)
    #
    # @example Create from Word Theme
    #   friendly = transformation.from_word(word_theme)
    class Theme < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :source, :string
      attribute :imported_at, :date_time
      attribute :color_scheme, ColorScheme
      attribute :font_scheme, FontScheme
      attribute :variants, :hash

      yaml do
        map "name", to: :name
        map "source", to: :source
        map "imported_at", to: :imported_at
        map "color_scheme", to: :color_scheme
        map "font_scheme", to: :font_scheme
        map "variants", to: :variants
      end

      # Load a bundled theme by name
      #
      # @param name [String] Theme name (e.g., 'atlas', 'badge')
      # @return [Theme] Loaded theme
      # @raise [ArgumentError] if theme not found
      def self.load(name)
        path = File.join(__dir__, "../../../data/themes", "#{name}.yml")
        unless File.exist?(path)
          raise ArgumentError,
                "Theme '#{name}' not found. Available: #{available_themes.join(", ")}"
        end

        from_yaml(File.read(path))
      end

      # List all available bundled themes
      #
      # @return [Array<String>] Theme names
      def self.available_themes
        theme_dir = File.join(__dir__, "../../../data/themes")
        return [] unless Dir.exist?(theme_dir)

        Dir.glob(File.join(theme_dir, "*.yml"))
           .map { |p| File.basename(p, ".yml") }
           .sort
      end

      # Convert to Word Theme for document generation
      #
      # @return [Drawingml::Theme] Word/OOXML theme
      def to_word_theme
        ThemeTransformation.new.to_word(self)
      end
    end
  end
end
