# frozen_string_literal: true

module Uniword
  module Resource
    # Loads standalone color scheme YAML files from data/color_schemes/
    class ColorSchemeLoader
      DATA_DIR = File.join(__dir__, "../../../data/color_schemes")

      # Load a color scheme by name
      #
      # @param name [String] Color scheme slug (e.g., "azure", "emerald")
      # @return [Themes::ColorScheme] The loaded color scheme
      # @raise [ArgumentError] if color scheme not found
      def self.load(name)
        path = File.join(DATA_DIR, "#{name}.yml")
        unless File.exist?(path)
          raise ArgumentError,
                "Color scheme '#{name}' not found. Available: #{available_schemes.join(', ')}"
        end

        Themes::ColorScheme.from_yaml(File.read(path))
      end

      # List all available bundled color schemes
      #
      # @return [Array<String>] Color scheme slugs
      def self.available_schemes
        return [] unless Dir.exist?(DATA_DIR)

        Dir.glob(File.join(DATA_DIR, "*.yml"))
           .map { |p| File.basename(p, ".yml") }
           .sort
      end
    end
  end
end
