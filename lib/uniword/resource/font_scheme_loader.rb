# frozen_string_literal: true

require "yaml"

module Uniword
  module Resource
    # Loads standalone font scheme YAML files from data/font_schemes/
    class FontSchemeLoader
      DATA_DIR = File.join(__dir__, "../../../data/font_schemes")

      # Load a font scheme by name
      #
      # @param name [String] Font scheme slug (e.g., "carlito_sans", "modern_office")
      # @return [Themes::FontScheme] The loaded font scheme
      # @raise [ArgumentError] if font scheme not found
      def self.load(name)
        path = File.join(DATA_DIR, "#{name}.yml")
        unless File.exist?(path)
          raise ArgumentError,
                "Font scheme '#{name}' not found. Available: #{available_schemes.join(", ")}"
        end

        raw = YAML.load_file(path)
        Themes::FontScheme.new(
          name: raw["name"],
          major_font: raw.dig("major", "latin"),
          minor_font: raw.dig("minor", "latin"),
          major_east_asian: raw.dig("major", "east_asian"),
          minor_east_asian: raw.dig("minor", "east_asian"),
          major_complex_script: raw.dig("major", "complex_script"),
          minor_complex_script: raw.dig("minor", "complex_script"),
          per_script: raw["per_script"],
          major_per_script: raw["major_per_script"],
          minor_per_script: raw["minor_per_script"]
        )
      end

      # List all available bundled font schemes
      #
      # @return [Array<String>] Font scheme slugs
      def self.available_schemes
        return [] unless Dir.exist?(DATA_DIR)

        Dir.glob(File.join(DATA_DIR, "*.yml"))
           .map { |p| File.basename(p, ".yml") }
           .sort
      end
    end
  end
end
