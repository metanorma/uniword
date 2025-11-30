# frozen_string_literal: true

require_relative 'thmx_package'

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
    class ThemePackage < ThmxPackage
      # Domain model loaded from package
      attr_reader :theme

      # Load Theme from package
      #
      # Extracts package and parses theme/theme/theme1.xml into Theme model.
      # Uses lutaml-model deserialization for XML parsing.
      #
      # @return [Theme] Loaded Theme model
      # @raise [ArgumentError] if package is invalid
      def load_content
        extract

        # Read theme XML
        theme_xml = read_theme

        # Parse into Theme using lutaml-model
        require_relative '../theme'
        @theme = Theme.from_xml(theme_xml)

        # Store source file reference
        @theme.source_file = path

        # Load media files
        @theme.media_files = load_media_files

        # Load variants (if any)
        @theme.variants = load_variants

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
        raise 'Must extract before saving' unless extracted_dir

        @theme = theme

        # Serialize Theme to XML using lutaml-model
        theme_xml = theme.to_xml

        # Write to package
        write_theme(theme_xml)

        # Save media files if any
        save_media_files(theme.media_files) if theme.media_files&.any?

        # Save variants if any
        save_variants(theme.variants) if theme.variants&.any?
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
        require_relative '../theme/media_file'

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
        require_relative '../theme/theme_variant'

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
