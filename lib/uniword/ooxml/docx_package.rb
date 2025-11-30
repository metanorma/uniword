# frozen_string_literal: true

require 'lutaml/model'
require_relative 'namespaces'
require_relative 'core_properties'
require_relative 'app_properties'
require_relative '../theme'
require_relative '../styles_configuration'
require_relative '../numbering_configuration'

module Uniword
  module Ooxml
    # DOCX Package - Complete OOXML package model
    #
    # Represents the entire .docx file structure as a lutaml-model object.
    # Each XML file within the ZIP is a separate lutaml-model class.
    #
    # This is the CORRECT OOP approach:
    # - ONE model class for the container
    # - Each XML part is a proper model attribute
    # - No serializer/deserializer anti-pattern
    #
    # @example Load DOCX
    #   package = DocxPackage.from_file('document.docx')
    #   package.core_properties.title = 'New Title'
    #   package.to_file('output.docx')
    class DocxPackage < Lutaml::Model::Serializable
      # Core document metadata
      attribute :core_properties, CoreProperties

      # Extended application properties
      attribute :app_properties, AppProperties

      # Document theme
      attribute :theme, Theme

      # Document styles configuration
      attribute :styles_configuration, StylesConfiguration

      # Document numbering configuration
      attribute :numbering_configuration, NumberingConfiguration

      # TODO: v2.0: Add proper lutaml-model attributes for:
      # - Document (word/document.xml)
      # - FontTable (word/fontTable.xml)
      # - Settings (word/settings.xml)
      # - WebSettings (word/webSettings.xml)
      # - Relationships (.rels files)
      # - ContentTypes ([Content_Types].xml)
      #
      # NO RAW XML STORAGE ALLOWED

      # Load DOCX package from file
      #
      # @param path [String] Path to .docx file
      # @return [DocxPackage] Loaded package
      def self.from_file(path)
        require_relative '../infrastructure/zip_extractor'

        extractor = Infrastructure::ZipExtractor.new
        zip_content = extractor.extract(path)

        from_zip_content(zip_content)
      end

      # Create package from extracted ZIP content
      #
      # @param zip_content [Hash] Extracted ZIP files
      # @return [DocxPackage] Package object
      def self.from_zip_content(zip_content)
        package = new

        # Parse lutaml-model files
        if zip_content['docProps/core.xml']
          package.core_properties = CoreProperties.from_xml(zip_content['docProps/core.xml'])
        end

        if zip_content['docProps/app.xml']
          package.app_properties = AppProperties.from_xml(zip_content['docProps/app.xml'])
        end

        if zip_content['word/theme/theme1.xml']
          package.theme = Theme.from_xml(zip_content['word/theme/theme1.xml'])
        end

        # Parse styles and numbering as models
        if zip_content['word/styles.xml']
          package.styles_configuration = StylesConfiguration.from_xml(zip_content['word/styles.xml'])
        end

        if zip_content['word/numbering.xml']
          package.numbering_configuration = NumberingConfiguration.from_xml(zip_content['word/numbering.xml'])
        end

        # Store raw document XML (will be parsed by DocxHandler)
        if zip_content['word/document.xml']
          package.raw_document_xml = zip_content['word/document.xml']
        end

        # TODO: v2.0: Parse fontTable.xml, settings.xml, webSettings.xml
        # TODO v2.0: Parse relationships and content types

        package
      end

      # Access raw document XML (for compatibility)
      attr_accessor :raw_document_xml

      # Save package to file
      #
      # @param path [String] Output path
      def to_file(path)
        require_relative '../infrastructure/zip_packager'

        zip_content = to_zip_content

        packager = Infrastructure::ZipPackager.new
        packager.package(zip_content, path)
      end

      # Generate ZIP content hash
      #
      # @return [Hash] File paths => content
      def to_zip_content
        content = {}

        # Serialize lutaml-model files with prefix: false
        if core_properties
          content['docProps/core.xml'] =
            core_properties.to_xml(encoding: 'UTF-8', prefix: false)
        end
        if app_properties
          content['docProps/app.xml'] =
            app_properties.to_xml(encoding: 'UTF-8', prefix: false)
        end

        # Theme serialization (no raw XML fallback)
        content['word/theme/theme1.xml'] = theme.to_xml(encoding: 'UTF-8') if theme

        # Serialize model-based configurations
        if styles_configuration
          content['word/styles.xml'] = styles_configuration.to_xml(encoding: 'UTF-8')
        end

        if numbering_configuration
          content['word/numbering.xml'] = numbering_configuration.to_xml(encoding: 'UTF-8')
        end

        # Serialize main document (word/document.xml)
        if @document
          content['word/document.xml'] = @document.to_xml(encoding: 'UTF-8')
        elsif @raw_document_xml
          # Fallback to raw XML if document wasn't parsed yet
          content['word/document.xml'] = @raw_document_xml
        end

        # TODO: v2.0: Serialize fontTable.xml, settings.xml, webSettings.xml
        # TODO v2.0: Serialize relationships and content types

        content
      end
    end
  end
end
