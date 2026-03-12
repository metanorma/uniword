# frozen_string_literal: true

module Uniword
  module Themes
    # Reads and extracts .thmx theme package files
    #
    # .thmx files are ZIP archives containing PowerPoint theme definitions
    # with optional variant packages. The actual Word theme is nested at
    # theme/theme/theme1.xml (not theme/theme1.xml as initially expected).
    #
    # @example Extract a theme package
    #   reader = ThemePackageReader.new
    #   files = reader.extract('Atlas.thmx')
    #   base_theme_xml = files[:base]
    #   variant_themes = files[:variants]
    class ThemePackageReader
      # Extract theme files from .thmx package
      #
      # @param path [String] Path to .thmx file
      # @return [Hash] Extracted theme data
      #   - :base => Base theme XML content (from theme/theme/theme1.xml)
      #   - :variants => Hash of variant_id => variant theme XML content
      #   - :variant_manager => Variant manager XML (if present)
      #   - :media => Hash of filename => MediaFile objects
      # @raise [ArgumentError] if file is invalid or missing required theme
      def extract(path)

        extractor = Infrastructure::ZipExtractor.new
        content = extractor.extract(path)

        # Extract base theme from corrected path
        base_theme_xml = content['theme/theme/theme1.xml']
        unless base_theme_xml
          raise ArgumentError,
                'Invalid theme package: missing theme/theme/theme1.xml'
        end

        # Extract variants
        variants = extract_variants(content)

        # Extract variant manager if present
        variant_manager_xml = content['themeVariants/themeVariantManager.xml']

        # Extract media files
        media = extract_media_files(content)

        {
          base: base_theme_xml,
          variants: variants,
          variant_manager: variant_manager_xml,
          media: media
        }
      end

      private

      # Extract variant themes from package
      #
      # @param content [Hash] All extracted files from .thmx
      # @return [Hash] variant_id => theme XML content
      def extract_variants(content)
        variants = {}

        content.each_key do |file_path|
          # Match pattern: themeVariants/variant{N}/theme/theme/theme1.xml
          next unless file_path =~ %r{^themeVariants/variant(\d+)/theme/theme/theme1\.xml$}

          variant_id = "variant#{Regexp.last_match(1)}"
          variants[variant_id] = content[file_path]
        end

        variants
      end

      # Extract media files from package
      #
      # Extracts images and other media from theme/media/ directory
      # Returns MediaFile objects for proper encapsulation
      #
      # @param content [Hash] All extracted files from .thmx
      # @return [Hash] filename => MediaFile object
      def extract_media_files(content)

        media = {}

        content.each_key do |file_path|
          # Match pattern: theme/media/{filename}
          next unless file_path =~ %r{^theme/media/(.+)$}

          filename = Regexp.last_match(1)

          # Create MediaFile value object
          media[filename] = MediaFile.new(
            filename: filename,
            content: content[file_path],
            source_path: file_path
          )
        end

        media
      end
    end
  end
end
