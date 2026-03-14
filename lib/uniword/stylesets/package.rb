# frozen_string_literal: true

module Uniword
  module Stylesets
    # Represents a .dotx StyleSet package (ZIP with word/styles.xml)
    #
    # Follows MODEL-DRIVEN architecture using lutaml-model for XML
    # deserialization. No manual parsing.
    #
    # @example Load StyleSet from .dotx
    #   package = Package.from_file('Distinctive.dotx')
    #   styleset = package.styleset
    #   puts styleset.name
    class Package < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST

      # word/styles.xml content (lutaml-model deserialization)
      attribute :styles_configuration, Uniword::Wordprocessingml::StylesConfiguration

      # Source .dotx file path (for reference)
      attribute :source_path, :string

      # Initialize Package
      #
      # @param attributes [Hash] Package attributes
      def initialize(attributes = {})
        super
        @styles_configuration ||= Uniword::Wordprocessingml::StylesConfiguration.new
      end

      # Load Package from .dotx file
      #
      # @param path [String] Path to .dotx file
      # @return [Package] Loaded package
      # @raise [ArgumentError] if file invalid
      # @raise [Uniword::CorruptedFileError] if ZIP corrupt
      #
      # @example
      #   pkg = Package.from_file('Distinctive.dotx')
      def self.from_file(path)
        # Validate file exists
        raise Uniword::FileNotFoundError, path unless File.exist?(path)

        # Extract ZIP
        extracted = extract_zip(path)

        # Deserialize styles.xml using lutaml-model (MODEL-DRIVEN!)
        styles_xml = extracted['word/styles.xml']
        raise Uniword::CorruptedFileError.new(path, 'styles.xml missing') unless styles_xml

        styles_config = StylesConfiguration.from_xml(styles_xml)

        # Create Package instance
        new(
          styles_configuration: styles_config,
          source_path: path
        )
      end

      # Convert to StyleSet model
      #
      # @return [StyleSet] StyleSet with styles from package
      def styleset
        StyleSet.new(
          name: extract_name,
          styles: styles_configuration.styles,
          source_file: source_path
        )
      end

      private

      # Extract ZIP contents
      #
      # @param path [String] ZIP file path
      # @return [Hash] Extracted files {path => content}
      def self.extract_zip(path)
        require 'zip'

        contents = {}
        Zip::File.open(path) do |zip|
          zip.each do |entry|
            next if entry.directory?

            contents[entry.name] = entry.get_input_stream.read
          end
        end
        contents
      rescue Zip::Error => e
        raise Uniword::CorruptedFileError.new(path, "Failed to extract: #{e.message}")
      end

      # Extract StyleSet name from source path
      #
      # @return [String] StyleSet name
      def extract_name
        return 'Custom StyleSet' unless source_path

        # Get filename without extension
        filename = File.basename(source_path, '.*')

        # Convert to title case (e.g., 'distinctive' -> 'Distinctive')
        filename.split(/[-_]/).map(&:capitalize).join(' ')
      end
    end
  end
end
