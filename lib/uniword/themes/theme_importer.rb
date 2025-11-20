# frozen_string_literal: true

require 'yaml'
require 'fileutils'

module Uniword
  module Themes
    # Imports .thmx theme files and converts them to YAML format
    #
    # Provides functionality to convert Office theme packages to
    # human-readable YAML files that can be bundled with the gem.
    #
    # @example Import single theme
    #   importer = ThemeImporter.new
    #   importer.import('Atlas.thmx', 'data/themes/atlas.yml')
    #
    # @example Import all themes from directory
    #   importer = ThemeImporter.new
    #   importer.import_all('themes/', 'data/themes/')
    class ThemeImporter
      # Import .thmx file to YAML
      #
      # @param thmx_path [String] Path to .thmx file
      # @param output_path [String] Output YAML path
      # @return [void]
      def import(thmx_path, output_path)
        require_relative '../theme/theme_loader'

        # Load theme using existing ThemeLoader
        loader = Themes::ThemeLoader.new
        theme = loader.load(thmx_path)

        # Convert to YAML-friendly hash
        theme_data = serialize_theme(theme, thmx_path)

        # Ensure output directory exists
        FileUtils.mkdir_p(File.dirname(output_path))

        # Write YAML file
        File.write(output_path, YAML.dump(theme_data))
      end

      # Import all themes from directory
      #
      # @param source_dir [String] Directory with .thmx files
      # @param output_dir [String] Output directory for YAML files
      # @return [Integer] Number of themes imported
      def import_all(source_dir, output_dir)
        count = 0

        Dir.glob(File.join(source_dir, '*.thmx')).each do |thmx_file|
          theme_name = theme_name_from_file(thmx_file)
          output_file = File.join(output_dir, "#{theme_name}.yml")

          puts "Importing #{File.basename(thmx_file)} -> #{File.basename(output_file)}"
          import(thmx_file, output_file)
          count += 1
        end

        count
      end

      private

      # Serialize theme to hash for YAML export
      #
      # @param theme [Theme] Theme to serialize
      # @param source_file [String] Original .thmx file path
      # @return [Hash] YAML-ready hash
      def serialize_theme(theme, source_file)
        {
          'name' => theme.name,
          'source' => File.basename(source_file),
          'imported_at' => Time.now.utc.iso8601,
          'color_scheme' => serialize_color_scheme(theme.color_scheme),
          'font_scheme' => serialize_font_scheme(theme.font_scheme),
          'variants' => serialize_variants(theme.variants)
        }
      end

      # Serialize color scheme to hash
      #
      # @param color_scheme [ColorScheme] Color scheme to serialize
      # @return [Hash] YAML-ready hash
      def serialize_color_scheme(color_scheme)
        {
          'name' => color_scheme.name,
          'colors' => color_scheme.colors.transform_keys(&:to_s).sort.to_h
        }
      end

      # Serialize font scheme to hash
      #
      # @param font_scheme [FontScheme] Font scheme to serialize
      # @return [Hash] YAML-ready hash
      def serialize_font_scheme(font_scheme)
        {
          'name' => font_scheme.name,
          'major_font' => font_scheme.major_font,
          'minor_font' => font_scheme.minor_font,
          'major_east_asian' => font_scheme.major_east_asian,
          'major_complex_script' => font_scheme.major_complex_script,
          'minor_east_asian' => font_scheme.minor_east_asian,
          'minor_complex_script' => font_scheme.minor_complex_script
        }
      end

      # Serialize variants to hash
      #
      # @param variants [Hash] Hash of variant_id => ThemeVariant
      # @return [Hash] YAML-ready hash
      def serialize_variants(variants)
        result = {}

        variants.each do |variant_id, variant|
          # Parse variant theme if not already parsed
          variant.parse_theme

          result[variant_id] = {
            'color_scheme' => serialize_color_scheme(variant.theme.color_scheme),
            'font_scheme' => serialize_font_scheme(variant.theme.font_scheme)
          }
        end

        result
      end

      # Convert file path to theme name for YAML file
      #
      # @param path [String] Path to .thmx file
      # @return [String] Theme name for YAML file
      def theme_name_from_file(path)
        File.basename(path, '.thmx')
          .downcase
          .gsub(/[^a-z0-9]+/, '_')
          .gsub(/^_|_$/, '')
      end
    end
  end
end