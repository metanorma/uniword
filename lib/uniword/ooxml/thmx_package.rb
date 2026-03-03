# frozen_string_literal: true

require 'lutaml/model'
require_relative 'namespaces'
require_relative '../theme'

module Uniword
  module Ooxml
    # THMX Package - Word Theme format
    #
    # Represents .thmx (theme) files, which are standalone theme packages.
    # Unlike DOCX/DOTX, THMX contains ONLY a theme1.xml file.
    #
    # This is the CORRECT OOP approach:
    # - ONE model class for the container
    # - Theme as the sole content attribute
    # - No serializer/deserializer anti-pattern
    #
    # @example Load theme
    #   theme = ThmxPackage.from_file('celestial.thmx')
    #   theme.name # => "Celestial"
    #
    # @example Save theme
    #   ThmxPackage.to_file(theme, 'output.thmx')
    class ThmxPackage < Lutaml::Model::Serializable
      # Theme (the only content in a .thmx file)
      attribute :theme, Theme

      # Load THMX package from file
      #
      # @param path [String] Path to .thmx file
      # @return [Theme] Loaded theme
      def self.from_file(path)
        require_relative '../infrastructure/zip_extractor'

        # Extract ZIP content
        extractor = Infrastructure::ZipExtractor.new
        zip_content = extractor.extract(path)

        # Parse package
        package = from_zip_content(zip_content)

        # Return theme directly (NOT a Document!)
        package.theme || Theme.new
      end

      # Create package from extracted ZIP content
      #
      # @param zip_content [Hash] Extracted ZIP files
      # @return [ThmxPackage] Package object
      def self.from_zip_content(zip_content)
        package = new

        # Parse theme (the only content)
        if zip_content['theme/theme/theme1.xml']
          package.theme = Theme.from_xml(zip_content['theme/theme/theme1.xml'])
        end

        package
      end

      # Access theme
      attr_accessor :theme

      # Get supported file extensions
      #
      # @return [Array<String>] Array of supported extensions
      def self.supported_extensions
        ['.thmx']
      end

      # Save theme to file
      #
      # @param theme [Theme] The theme to save
      # @param path [String] Output path
      def self.to_file(theme, path)
        require_relative '../infrastructure/zip_packager'

        # Create package
        package = new
        package.theme = theme

        # Generate ZIP content
        zip_content = package.to_zip_content

        # Add required OOXML infrastructure files
        add_required_files(zip_content)

        # Package and save
        packager = Infrastructure::ZipPackager.new
        packager.package(zip_content, path)
      end

      # Generate ZIP content hash
      #
      # @return [Hash] File paths => content
      def to_zip_content
        content = {}

        # Serialize theme (the only content)
        if theme
          content['theme/theme/theme1.xml'] = theme.to_xml(encoding: 'UTF-8')
        end

        content
      end

      # Add required OOXML files for a valid THMX package
      #
      # @param zip_content [Hash] The ZIP content hash
      # @return [void]
      def self.add_required_files(zip_content)
        # Add [Content_Types].xml if not present
        unless zip_content['[Content_Types].xml']
          require_relative '../content_types'
          zip_content['[Content_Types].xml'] =
            ContentTypes.generate_for_theme.to_xml(declaration: true)
        end

        # Add _rels/.rels if not present
        unless zip_content['_rels/.rels']
          require_relative '../relationships/relationships'
          zip_content['_rels/.rels'] =
            Relationships::Relationships.generate_theme_package_rels.to_xml(declaration: true)
        end

        # Add theme/_rels/theme1.xml.rels if not present (optional but recommended)
        unless zip_content['theme/_rels/theme1.xml.rels']
          zip_content['theme/_rels/theme1.xml.rels'] =
            Relationships::Relationships.generate_theme_rels.to_xml(declaration: true)
        end
      end

      private_class_method :add_required_files
    end
  end
end
