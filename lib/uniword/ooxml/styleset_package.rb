# frozen_string_literal: true

module Uniword
  module Ooxml
    # Specialized package handler for StyleSet (.dotx) files
    #
    # StyleSets are stored in .dotx Word template files with style
    # definitions in word/styles.xml. This class bridges the package
    # infrastructure with StyleSet model serialization.
    #
    # @example Load a StyleSet
    #   package = StyleSetPackage.new(path: 'Distinctive.dotx')
    #   styleset = package.load_content
    #   puts styleset.name
    #   package.cleanup
    #
    # @example Save a StyleSet
    #   package = StyleSetPackage.new(path: 'template.dotx')
    #   package.extract
    #   package.save_content(my_styleset)
    #   package.package('output.dotx')
    #   package.cleanup
    class StyleSetPackage < DotxPackage
      # Domain model loaded from package
      attr_reader :styleset

      # Load StyleSet from package
      #
      # Extracts package and parses word/styles.xml into StyleSet model.
      # Uses existing StyleSetXmlParser for XML parsing.
      #
      # @return [StyleSet] Loaded StyleSet model
      # @raise [ArgumentError] if package is invalid
      def load_content
        extract

        # Read styles XML
        styles_xml = read_styles

        # Parse into StyleSet using existing parser
        parser = StyleSets::StyleSetXmlParser.new
        @styleset = parser.parse(styles_xml)

        # Store source file reference
        @styleset.source_file = path

        @styleset
      end

      # Save StyleSet to package
      #
      # Serializes StyleSet model to word/styles.xml using lutaml-model.
      # Preserves other package files unchanged.
      #
      # @param styleset [StyleSet] StyleSet model to save
      # @return [void]
      # @raise [RuntimeError] if package not extracted
      def save_content(styleset)
        raise 'Must extract before saving' unless extracted_dir

        @styleset = styleset

        # Serialize StyleSet to XML using lutaml-model
        styles_xml = serialize_styleset(styleset)

        # Write to package
        write_styles(styles_xml)
      end

      # Convenience: Load StyleSet from file
      #
      # @param path [String] Path to .dotx file
      # @return [StyleSet] Loaded StyleSet
      def self.load_from_file(path)
        package = new(path: path)
        styleset = package.load_content
        package.cleanup
        styleset
      end

      # Convenience: Save StyleSet to file
      #
      # Creates new .dotx package with StyleSet, using template as base.
      #
      # @param styleset [StyleSet] StyleSet to save
      # @param output_path [String] Output .dotx file path
      # @param template_path [String] Template .dotx to base on
      # @return [String] Path to created file
      def self.save_to_file(styleset, output_path, template_path:)
        package = new(path: template_path)
        package.extract
        package.save_content(styleset)
        package.package(output_path)
        package.cleanup

        output_path
      end

      private

      # Serialize StyleSet to XML
      #
      # Uses lutaml-model serialization with proper namespaces.
      # This should generate XML compatible with word/styles.xml format.
      #
      # @param styleset [StyleSet] StyleSet to serialize
      # @return [String] Serialized XML
      def serialize_styleset(styleset)
        # Create StylesConfiguration from StyleSet
        config = StylesConfiguration.new

        # Copy styles from styleset
        styleset.styles.each do |style|
          config.styles << style
        end

        # Serialize to XML using lutaml-model
        config.to_xml
      end
    end
  end
end
