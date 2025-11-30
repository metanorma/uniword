# frozen_string_literal: true

require_relative 'package_file'

module Uniword
  module Ooxml
    # Package handler for theme files (.thmx)
    #
    # .thmx files are ZIP packages containing PowerPoint theme definitions:
    # - theme/theme/theme1.xml: Main theme definition
    # - theme/media/: Theme images and media
    # - themeVariants/: Theme variant packages
    # - [Content_Types].xml: Content type declarations
    #
    # Note: The theme structure is nested - theme1.xml is at
    # theme/theme/theme1.xml, not theme/theme1.xml as might be expected.
    #
    # @example Access theme1.xml
    #   package = ThmxPackage.new(path: 'MyTheme.thmx')
    #   package.extract
    #   theme_xml = package.read_theme
    #   package.write_theme(modified_xml)
    #   package.package('output.thmx')
    #   package.cleanup
    class ThmxPackage < PackageFile
      # Theme directory within package
      THEME_DIR = 'theme'

      # Common file paths within package
      THEME_XML_PATH = 'theme/theme/theme1.xml'
      THEME_MEDIA_DIR = 'theme/media'
      VARIANTS_DIR = 'themeVariants'
      CONTENT_TYPES_PATH = '[Content_Types].xml'

      # Read theme1.xml from package
      #
      # @return [String] Theme XML content
      # @raise [Errno::ENOENT] if theme1.xml not found
      def read_theme
        read_file(THEME_XML_PATH)
      end

      # Write theme1.xml to package
      #
      # @param xml [String] Theme XML content
      # @return [void]
      def write_theme(xml)
        write_file(THEME_XML_PATH, xml)
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

      # Check if package has theme1.xml
      #
      # @return [Boolean] true if theme1.xml exists
      def has_theme?
        file_exists?(THEME_XML_PATH)
      end

      # List all media files in theme/media/
      #
      # @return [Array<String>] Relative paths of media files
      def media_files
        return [] unless extracted_dir

        pattern = File.join(extracted_dir, THEME_MEDIA_DIR, '*')
        Dir.glob(pattern).select { |f| File.file?(f) }
           .map { |f| f.sub("#{extracted_dir}/", '') }
      end

      # Read a media file from package
      #
      # @param filename [String] Media filename (e.g., 'image1.png')
      # @return [String] Binary content of media file
      # @raise [Errno::ENOENT] if file not found
      def read_media(filename)
        path = File.join(THEME_MEDIA_DIR, filename)
        read_file(path)
      end

      # Write a media file to package
      #
      # @param filename [String] Media filename
      # @param content [String] Binary content
      # @return [void]
      def write_media(filename, content)
        path = File.join(THEME_MEDIA_DIR, filename)
        write_file(path, content)
      end

      # List all theme variants
      #
      # Returns variant IDs (e.g., 'variant1', 'variant2')
      #
      # @return [Array<String>] Variant identifiers
      def variants
        return [] unless extracted_dir

        pattern = File.join(extracted_dir, VARIANTS_DIR, 'variant*')
        Dir.glob(pattern).select { |f| File.directory?(f) }
           .map { |f| File.basename(f) }
           .sort
      end

      # Read a variant's theme XML
      #
      # @param variant_id [String] Variant identifier (e.g., 'variant1')
      # @return [String] Variant theme XML content
      # @raise [Errno::ENOENT] if variant not found
      def read_variant(variant_id)
        path = File.join(VARIANTS_DIR, variant_id, 'theme/theme/theme1.xml')
        read_file(path)
      end

      # Write a variant's theme XML
      #
      # @param variant_id [String] Variant identifier
      # @param xml [String] Variant theme XML content
      # @return [void]
      def write_variant(variant_id, xml)
        path = File.join(VARIANTS_DIR, variant_id, 'theme/theme/theme1.xml')
        write_file(path, xml)
      end

      # Check if package has a specific variant
      #
      # @param variant_id [String] Variant identifier
      # @return [Boolean] true if variant exists
      def has_variant?(variant_id)
        path = File.join(VARIANTS_DIR, variant_id, 'theme/theme/theme1.xml')
        file_exists?(path)
      end

      # List all files in theme/ directory
      #
      # @return [Array<String>] Relative paths of files in theme/
      def theme_files
        return [] unless extracted_dir

        pattern = File.join(extracted_dir, THEME_DIR, '**', '*')
        Dir.glob(pattern).select { |f| File.file?(f) }
           .map { |f| f.sub("#{extracted_dir}/", '') }
      end
    end
  end
end