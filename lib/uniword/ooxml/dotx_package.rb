# frozen_string_literal: true

require_relative 'package_file'

module Uniword
  module Ooxml
    # Package handler for Word template files (.dotx)
    #
    # .dotx files are ZIP packages containing Word document structure with:
    # - word/document.xml: Main document content
    # - word/styles.xml: Style definitions
    # - word/numbering.xml: Numbering definitions
    # - word/_rels/: Relationships
    # - [Content_Types].xml: Content type declarations
    #
    # This class provides common structure and helper methods for
    # specialized .dotx packages like StyleSetPackage.
    #
    # @example Access styles.xml
    #   package = DotxPackage.new(path: 'template.dotx')
    #   package.extract
    #   styles_xml = package.read_styles
    #   package.write_styles(modified_xml)
    #   package.package('output.dotx')
    #   package.cleanup
    class DotxPackage < PackageFile
      # Word document directory within package
      WORD_DIR = 'word'

      # Common file paths within package
      DOCUMENT_XML_PATH = 'word/document.xml'
      STYLES_XML_PATH = 'word/styles.xml'
      NUMBERING_XML_PATH = 'word/numbering.xml'
      SETTINGS_XML_PATH = 'word/settings.xml'
      CONTENT_TYPES_PATH = '[Content_Types].xml'

      # Read styles.xml from package
      #
      # @return [String] Styles XML content
      # @raise [Errno::ENOENT] if styles.xml not found
      def read_styles
        read_file(STYLES_XML_PATH)
      end

      # Write styles.xml to package
      #
      # @param xml [String] Styles XML content
      # @return [void]
      def write_styles(xml)
        write_file(STYLES_XML_PATH, xml)
      end

      # Read document.xml from package
      #
      # @return [String] Document XML content
      # @raise [Errno::ENOENT] if document.xml not found
      def read_document
        read_file(DOCUMENT_XML_PATH)
      end

      # Write document.xml to package
      #
      # @param xml [String] Document XML content
      # @return [void]
      def write_document(xml)
        write_file(DOCUMENT_XML_PATH, xml)
      end

      # Read numbering.xml from package
      #
      # @return [String, nil] Numbering XML content, or nil if not present
      def read_numbering
        return nil unless file_exists?(NUMBERING_XML_PATH)

        read_file(NUMBERING_XML_PATH)
      end

      # Write numbering.xml to package
      #
      # @param xml [String] Numbering XML content
      # @return [void]
      def write_numbering(xml)
        write_file(NUMBERING_XML_PATH, xml)
      end

      # Read settings.xml from package
      #
      # @return [String, nil] Settings XML content, or nil if not present
      def read_settings
        return nil unless file_exists?(SETTINGS_XML_PATH)

        read_file(SETTINGS_XML_PATH)
      end

      # Write settings.xml to package
      #
      # @param xml [String] Settings XML content
      # @return [void]
      def write_settings(xml)
        write_file(SETTINGS_XML_PATH, xml)
      end

      # Read [Content_Types].xml from package
      #
      # @return [String] Content types XML
      # @raise [Errno::ENOENT] if [Content_Types].xml not found
      def read_content_types
        read_file(CONTENT_TYPES_PATH)
      end

      # Write [Content_Types].xml to package
      #
      # @param xml [String] Content types XML
      # @return [void]
      def write_content_types(xml)
        write_file(CONTENT_TYPES_PATH, xml)
      end

      # Check if package has styles.xml
      #
      # @return [Boolean] true if styles.xml exists
      def has_styles?
        file_exists?(STYLES_XML_PATH)
      end

      # Check if package has numbering.xml
      #
      # @return [Boolean] true if numbering.xml exists
      def has_numbering?
        file_exists?(NUMBERING_XML_PATH)
      end

      # List all files in word/ directory
      #
      # @return [Array<String>] Relative paths of files in word/
      def word_files
        return [] unless extracted_dir

        pattern = File.join(extracted_dir, WORD_DIR, '**', '*')
        Dir.glob(pattern).select { |f| File.file?(f) }
           .map { |f| f.sub("#{extracted_dir}/", '') }
      end
    end
  end
end
