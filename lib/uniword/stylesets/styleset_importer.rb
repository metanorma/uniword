# frozen_string_literal: true

require "fileutils"

module Uniword
  module Stylesets
    # Imports .dotx StyleSet files and converts them to YAML format
    #
    # Leverages lutaml-model's from_xml and to_yaml serialization for
    # simple, reliable conversion from .dotx to YAML format.
    #
    # @example Import single StyleSet
    #   importer = StyleSetImporter.new
    #   importer.import('Distinctive.dotx', 'data/stylesets/distinctive.yml')
    #
    # @example Import all StyleSets from directory
    #   importer = StyleSetImporter.new
    #   importer.import_all('stylesets/', 'data/stylesets/')
    class StyleSetImporter
      # Import .dotx file to YAML
      #
      # @param dotx_path [String] Path to .dotx file
      # @param output_path [String] Output YAML path
      # @return [void]
      def import(dotx_path, output_path)
        # Extract .dotx package
        reader = StyleSetPackageReader.new
        files = reader.extract(dotx_path)

        # Parse styles.xml using lutaml-model
        styles_config = ::Uniword::Wordprocessingml::StylesConfiguration.from_xml(
          files[:styles],
          encoding: "UTF-8",
        )

        # Create StyleSet model
        styleset = ::Uniword::StyleSet.new(
          name: extract_name_from_path(dotx_path),
          styles: styles_config.styles,
          source_file: File.basename(dotx_path),
        )

        # Ensure output directory exists
        FileUtils.mkdir_p(File.dirname(output_path))

        # Serialize to YAML using lutaml-model
        File.write(output_path, styleset.to_yaml)
      end

      # Import all StyleSets from directory
      #
      # @param source_dir [String] Directory with .dotx files
      # @param output_dir [String] Output directory for YAML files
      # @return [Integer] Number of StyleSets imported
      def import_all(source_dir, output_dir)
        count = 0

        Dir.glob(File.join(source_dir, "*.dotx")).each do |dotx_file|
          styleset_name = styleset_name_from_file(dotx_file)
          output_file = File.join(output_dir, "#{styleset_name}.yml")

          puts "Importing #{File.basename(dotx_file)} -> #{File.basename(output_file)}"
          import(dotx_file, output_file)
          count += 1
        end

        count
      end

      private

      # Extract StyleSet name from file path
      #
      # @param path [String] Path to .dotx file
      # @return [String] StyleSet name (e.g., 'Distinctive')
      def extract_name_from_path(path)
        # Get filename without extension
        filename = File.basename(path, ".*")

        # Convert to title case (e.g., 'distinctive' -> 'Distinctive')
        filename.split(/[-_]/).map(&:capitalize).join(" ")
      end

      # Convert file path to StyleSet name for YAML filename
      #
      # @param path [String] Path to .dotx file
      # @return [String] StyleSet name for YAML file (e.g., 'distinctive')
      def styleset_name_from_file(path)
        File.basename(path, ".dotx")
          .downcase
          .gsub(/[^a-z0-9]+/, "_")
          .gsub(/^_|_$/, "")
      end
    end
  end
end
