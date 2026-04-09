# frozen_string_literal: true

module Uniword
  module Stylesets
    # Loads StyleSets from YAML files
    #
    # Leverages lutaml-model's from_yaml deserialization for simple,
    # reliable loading of YAML StyleSet files.
    #
    # @example Load from YAML file
    #   loader = YamlStyleSetLoader.new
    #   styleset = loader.load('custom_styleset.yml')
    #
    # @example Load bundled StyleSet
    #   styleset = YamlStyleSetLoader.load_bundled('distinctive')
    class YamlStyleSetLoader
      # Load StyleSet from YAML file
      #
      # @param path [String] Path to YAML file
      # @return [StyleSet] Loaded StyleSet
      def load(path)

        # Use lutaml-model deserialization
        ::Uniword::StyleSet.from_yaml(File.read(path))
      end

      # List all available bundled StyleSets
      #
      # @return [Array<String>] StyleSet names
      def self.available_stylesets
        styleset_dir = File.join(__dir__, '../../../data/stylesets')
        return [] unless Dir.exist?(styleset_dir)

        Dir.glob(File.join(styleset_dir, '*.yml')).map do |path|
          File.basename(path, '.yml')
        end.sort
      end

      # Load bundled StyleSet by name
      #
      # @param name [String] StyleSet name (e.g., 'distinctive', 'basic')
      # @return [StyleSet] Loaded StyleSet
      # @raise [ArgumentError] if StyleSet not found
      def self.load_bundled(name)
        styleset_dir = File.join(__dir__, '../../../data/stylesets')
        path = File.join(styleset_dir, "#{name}.yml")

        unless File.exist?(path)
          available = available_stylesets
          raise ArgumentError,
                "StyleSet '#{name}' not found. " \
                "Available StyleSets: #{available.join(', ')}"
        end

        new.load(path)
      end
    end
  end
end
