# frozen_string_literal: true

require 'yaml'

module Uniword
  module Themes
    # Loads themes from YAML files
    #
    # Provides functionality to load themes from YAML format,
    # including bundled themes that ship with the gem.
    #
    # @example Load from YAML file
    #   loader = YamlThemeLoader.new
    #   theme = loader.load('custom_theme.yml')
    #
    # @example Load bundled theme
    #   theme = YamlThemeLoader.load_bundled('atlas', variant: 2)
    class YamlThemeLoader
      # Load theme from YAML file
      #
      # @param path [String] Path to YAML file
      # @param variant [String, Integer, nil] Optional variant to apply
      # @return [Theme] Loaded theme
      def load(path, variant: nil)
        data = YAML.load_file(path)

        # Create theme from YAML data
        theme = deserialize_theme(data)

        # Apply variant if specified
        if variant
          variant_key = normalize_variant_id(variant)
          unless data['variants'] && data['variants'][variant_key]
            raise ArgumentError,
                  "Variant '#{variant}' not found in theme. " \
                  "Available: #{data['variants']&.keys&.join(', ') || 'none'}"
          end
          apply_variant(theme, data['variants'][variant_key])
        end

        theme
      end

      # List all available bundled themes
      #
      # @return [Array<String>] Theme names
      def self.available_themes
        theme_dir = File.join(__dir__, '../../../data/themes')
        return [] unless Dir.exist?(theme_dir)

        Dir.glob(File.join(theme_dir, '*.yml')).map do |path|
          File.basename(path, '.yml')
        end.sort
      end

      # Load bundled theme by name
      #
      # @param name [String] Theme name (e.g., 'atlas', 'office_theme')
      # @param variant [String, Integer, nil] Optional variant
      # @return [Theme] Loaded theme
      # @raise [ArgumentError] if theme not found
      def self.load_bundled(name, variant: nil)
        theme_dir = File.join(__dir__, '../../../data/themes')
        path = File.join(theme_dir, "#{name}.yml")

        unless File.exist?(path)
          available = available_themes
          raise ArgumentError,
                "Theme '#{name}' not found. " \
                "Available themes: #{available.join(', ')}"
        end

        new.load(path, variant: variant)
      end

      private

      # Deserialize theme from YAML data
      #
      # @param data [Hash] YAML data
      # @return [Theme] Deserialized theme
      def deserialize_theme(data)
        require_relative '../theme'

        theme = ::Uniword::Theme.new(name: data['name'])

        # Deserialize color scheme
        if data['color_scheme']
          theme.color_scheme = deserialize_color_scheme(data['color_scheme'])
        end

        # Deserialize font scheme
        if data['font_scheme']
          theme.font_scheme = deserialize_font_scheme(data['font_scheme'])
        end

        # Deserialize variants
        if data['variants']
          theme.variants = deserialize_variants(data['variants'])
        end

        # Set source reference
        theme.source_file = data['source'] if data['source']

        theme
      end

      # Deserialize color scheme from YAML data
      #
      # @param data [Hash] Color scheme data
      # @return [ColorScheme] Deserialized color scheme
      def deserialize_color_scheme(data)
        require_relative '../color_scheme'

        scheme = ColorScheme.new(name: data['name'])

        if data['colors']
          data['colors'].each do |color_name, color_value|
            scheme[color_name.to_sym] = color_value if color_value
          end
        end

        scheme
      end

      # Deserialize font scheme from YAML data
      #
      # @param data [Hash] Font scheme data
      # @return [FontScheme] Deserialized font scheme
      def deserialize_font_scheme(data)
        require_relative '../font_scheme'

        scheme = FontScheme.new(name: data['name'])
        scheme.major_font = data['major_font']
        scheme.minor_font = data['minor_font']
        scheme.major_east_asian = data['major_east_asian']
        scheme.major_complex_script = data['major_complex_script']
        scheme.minor_east_asian = data['minor_east_asian']
        scheme.minor_complex_script = data['minor_complex_script']
        scheme
      end

      # Deserialize variants from YAML data
      #
      # @param variants_data [Hash] Variants data
      # @return [Hash] Hash of variant_id => ThemeVariant
      def deserialize_variants(variants_data)
        require_relative '../theme/theme_variant'

        variants = {}

        variants_data.each do |variant_id, variant_data|
          variant = ThemeVariant.new(variant_id)

          # Create a theme for this variant
          variant_theme = ::Uniword::Theme.new
          if variant_data['color_scheme']
            variant_theme.color_scheme =
              deserialize_color_scheme(variant_data['color_scheme'])
          end
          if variant_data['font_scheme']
            variant_theme.font_scheme =
              deserialize_font_scheme(variant_data['font_scheme'])
          end

          variant.theme = variant_theme
          variants[variant_id] = variant
        end

        variants
      end

      # Apply variant to theme
      #
      # @param theme [Theme] Theme to modify
      # @param variant_data [Hash] Variant data
      # @return [void]
      def apply_variant(theme, variant_data)
        return unless variant_data

        # Apply variant colors
        if variant_data['color_scheme'] && variant_data['color_scheme']['colors']
          variant_data['color_scheme']['colors'].each do |color_name, color_value|
            theme.color_scheme[color_name.to_sym] = color_value if color_value
          end
        end

        # Apply variant fonts
        if variant_data['font_scheme']
          fs = variant_data['font_scheme']
          theme.font_scheme.major_font = fs['major_font'] if fs['major_font']
          theme.font_scheme.minor_font = fs['minor_font'] if fs['minor_font']
        end
      end

      # Normalize variant ID to standard format
      #
      # @param variant_id [String, Integer] Variant identifier
      # @return [String] Normalized variant ID
      def normalize_variant_id(variant_id)
        case variant_id
        when Integer
          "variant#{variant_id}"
        when /^\d+$/
          "variant#{variant_id}"
        else
          variant_id.to_s
        end
      end
    end
  end
end