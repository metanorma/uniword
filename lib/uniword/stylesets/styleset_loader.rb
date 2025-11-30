# frozen_string_literal: true

module Uniword
  module StyleSets
    # Orchestrates StyleSet loading from .dotx files
    #
    # Coordinates between StyleSetPackageReader and StyleSetXmlParser
    # to load StyleSets from .dotx packages.
    #
    # @example Load a StyleSet
    #   loader = StyleSetLoader.new
    #   styleset = loader.load('Distinctive.dotx')
    #   puts styleset.name
    #   puts "Styles: #{styleset.styles.count}"
    class StyleSetLoader
      # Load StyleSet from .dotx file
      #
      # @param path [String] Path to .dotx file
      # @return [StyleSet] Loaded StyleSet
      # @raise [ArgumentError] if file is invalid
      def load(path)
        require_relative 'styleset_package_reader'
        require_relative 'styleset_xml_parser'
        require_relative '../styleset'

        # Extract package
        reader = StyleSetPackageReader.new
        extracted = reader.extract(path)

        # Parse styles
        parser = StyleSetXmlParser.new
        styles = parser.parse(extracted[:styles])

        # Extract name from file path (e.g., 'Distinctive.dotx' -> 'Distinctive')
        name = extract_name_from_path(path)

        # Create StyleSet model
        styleset = ::Uniword::StyleSet.new(
          name: name,
          styles: styles
        )

        # Store source file reference
        styleset.source_file = path

        styleset
      end

      private

      # Extract StyleSet name from file path
      #
      # @param path [String] Path to .dotx file
      # @return [String] StyleSet name
      def extract_name_from_path(path)
        # Get filename without extension
        filename = File.basename(path, '.*')

        # Convert to title case (e.g., 'distinctive' -> 'Distinctive')
        filename.split(/[-_]/).map(&:capitalize).join(' ')
      end
    end
  end
end
