# frozen_string_literal: true

module Uniword
  module Ooxml
    # Specialized package handler for Theme (.thmx) files
    #
    # Themes are stored in .thmx PowerPoint theme files with the main
    # theme definition at theme/theme/theme1.xml. This class bridges
    # the package infrastructure with Theme model serialization.
    #
    # @example Load a Theme
    #   package = ThemePackage.new(path: 'Atlas.thmx')
    #   theme = package.load_content
    #   puts theme.name
    #   package.cleanup
    #
    # @example Save a Theme
    #   package = ThemePackage.new(path: 'template.thmx')
    #   package.extract
    #   package.save_content(my_theme)
    #   package.package('output.thmx')
    #   package.cleanup
    class ThemePackage
      # Source file path
      attr_accessor :path

      # Extracted content (Hash of file paths => content)
      attr_accessor :extracted_content

      # Domain model loaded from package
      attr_reader :theme

      # Initialize with file path
      #
      # @param path [String] Path to .thmx file
      def initialize(path:)
        @path = path
        @extracted_content = nil
        @theme = nil
      end

      # Extract ZIP package
      #
      # @return [void]
      def extract
        extractor = Infrastructure::ZipExtractor.new
        @extracted_content = extractor.extract(@path)
      end

      # Check if extracted
      #
      # @return [Boolean]
      def extracted_dir
        @extracted_content
      end

      # Cleanup extracted content (no-op since we use memory)
      #
      # @return [void]
      def cleanup
        @extracted_content = nil
      end

      # Read theme XML from extracted package
      #
      # @return [String] Theme XML content
      def read_theme
        raise 'Must extract before reading' unless @extracted_content

        @extracted_content['theme/theme/theme1.xml']
      end

      # Load Theme from package
      #
      # Extracts package and parses theme/theme/theme1.xml into Theme model.
      # Uses lutaml-model deserialization for XML parsing.
      #
      # @return [Theme] Loaded Theme model
      # @raise [ArgumentError] if package is invalid
      def load_content
        extract unless @extracted_content

        # Read theme XML
        theme_xml = read_theme

        # Parse into Theme using lutaml-model
        @theme = Drawingml::Theme.from_xml(theme_xml)

        # Store source file reference
        @theme.source_file = path if @theme

        @theme
      end

      # Save Theme to package
      #
      # Serializes Theme model to theme/theme/theme1.xml using lutaml-model.
      # Preserves media files and variants unchanged.
      #
      # @param theme [Theme] Theme model to save
      # @return [void]
      # @raise [RuntimeError] if package not extracted
      def save_content(theme)
        raise 'Must extract before saving' unless @extracted_content

        @theme = theme

        # Serialize Theme to XML using lutaml-model with prefix: true
        # to preserve namespace prefixes for cross-namespace elements
        theme_xml = theme.to_xml(prefix: true)

        # Update content hash
        @extracted_content['theme/theme/theme1.xml'] = theme_xml
      end

      # Package extracted content into ZIP file
      #
      # @param output_path [String] Path to output .thmx file
      # @return [void]
      # @raise [RuntimeError] if package not extracted
      def package(output_path)
        raise 'Must extract before packaging' unless @extracted_content

        packager = Infrastructure::ZipPackager.new
        packager.package(@extracted_content, output_path)
      end

      # Convenience: Load Theme from file
      #
      # @param path [String] Path to .thmx file
      # @return [Theme] Loaded Theme
      def self.load_from_file(path)
        package = new(path: path)
        theme = package.load_content
        package.cleanup
        theme
      end

      # Convenience: Save Theme to file
      #
      # Creates new .thmx package with Theme, using template as base.
      #
      # @param theme [Theme] Theme to save
      # @param output_path [String] Output .thmx file path
      # @param template_path [String] Template .thmx to base on
      # @return [String] Path to created file
      def self.save_to_file(theme, output_path, template_path:)
        package = new(path: template_path)
        package.extract
        package.save_content(theme)
        package.package(output_path)
        package.cleanup

        output_path
      end

      private

      # Load media files from package
      #
      # @return [Hash] filename => MediaFile objects
      def load_media_files
        media = {}

        media_files.each do |file_path|
          filename = File.basename(file_path)
          content = read_media(filename)

          media[filename] = Themes::MediaFile.new(
            filename: filename,
            content: content,
            source_path: file_path
          )
        end

        media
      end

      # Save media files to package
      #
      # @param media_files [Hash] filename => MediaFile objects
      # @return [void]
      def save_media_files(media_files)
        media_files.each do |filename, media_file|
          write_media(filename, media_file.content)
        end
      end

      # Load theme variants from package
      #
      # @return [Hash] variant_id => ThemeVariant
      def load_variants
        variant_hash = {}

        variants.each do |variant_id|
          variant_xml = read_variant(variant_id)
          variant = Themes::ThemeVariant.new(variant_id, theme_xml: variant_xml)
          variant_hash[variant_id] = variant
        end

        variant_hash
      end

      # Save theme variants to package
      #
      # @param variants [Hash] variant_id => ThemeVariant
      # @return [void]
      def save_variants(variants)
        variants.each do |variant_id, variant|
          # Get variant's theme XML
          variant_xml = if variant.theme
                          variant.theme.to_xml
                        else
                          variant.theme_xml
                        end

          write_variant(variant_id, variant_xml) if variant_xml
        end
      end
    end
  end
end
