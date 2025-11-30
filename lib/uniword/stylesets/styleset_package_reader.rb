# frozen_string_literal: true

module Uniword
  module StyleSets
    # Reads and extracts .dotx StyleSet package files
    #
    # .dotx files are ZIP archives containing Word template definitions
    # with style collections stored in word/styles.xml.
    #
    # @example Extract a StyleSet package
    #   reader = StyleSetPackageReader.new
    #   files = reader.extract('Distinctive.dotx')
    #   styles_xml = files[:styles]
    class StyleSetPackageReader
      # Extract StyleSet files from .dotx package
      #
      # @param path [String] Path to .dotx file
      # @return [Hash] Extracted StyleSet data
      #   - :styles => Styles XML content (from word/styles.xml)
      #   - :theme => Optional theme XML (from word/theme/theme1.xml)
      #   - :fonts => Optional font table (from word/fontTable.xml)
      # @raise [ArgumentError] if file is invalid or missing required styles
      def extract(path)
        require_relative '../infrastructure/zip_extractor'

        extractor = Infrastructure::ZipExtractor.new
        content = extractor.extract(path)

        # Extract styles.xml (required for StyleSets)
        styles_xml = content['word/styles.xml']
        unless styles_xml
          raise ArgumentError,
                'Invalid StyleSet package: missing word/styles.xml'
        end

        # Extract optional components
        theme_xml = content['word/theme/theme1.xml']
        fonts_xml = content['word/fontTable.xml']

        {
          styles: styles_xml,
          theme: theme_xml,
          fonts: fonts_xml
        }
      end
    end
  end
end
