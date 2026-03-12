# frozen_string_literal: true

require 'lutaml/model'
# Theme, StylesConfiguration, NumberingConfiguration, Document are autoloaded via lib/uniword.rb

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
      # @return [Document] Loaded document (Generated::Wordprocessingml::DocumentRoot)
      def self.from_file(path)

        # Extract ZIP content
        extractor = Infrastructure::ZipExtractor.new
        zip_content = extractor.extract(path)

        # Parse package with properties and theme
        package = from_zip_content(zip_content)

        # Parse main document XML using generated classes
        # Document is Uniword::Wordprocessingml::DocumentRoot
        document = if package.raw_document_xml
                     Uniword::Wordprocessingml::DocumentRoot.from_xml(package.raw_document_xml)
                   else
                     Uniword::Wordprocessingml::DocumentRoot.new
                   end

        # Transfer properties from package to document
        document.core_properties = package.core_properties if package.core_properties
        document.app_properties = package.app_properties if package.app_properties
        document.theme = package.theme if package.theme

        # Transfer model-based configurations
        document.styles_configuration = package.styles_configuration if package.styles_configuration
        if package.numbering_configuration
          document.numbering_configuration = package.numbering_configuration
        end

        document
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

      # Get supported file extensions
      #
      # @return [Array<String>] Array of supported extensions
      def self.supported_extensions
        ['.docx']
      end

      # Save document to file
      #
      # @param document [Document] The document to save (Generated::Wordprocessingml::DocumentRoot)
      # @param path [String] Output path
      def self.to_file(document, path)

        # Create package
        package = new

        # Transfer properties to package
        package.core_properties = document.core_properties || CoreProperties.new
        package.app_properties = document.app_properties || AppProperties.new
        package.theme = document.theme

        # Transfer model-based configurations
        package.styles_configuration = document.styles_configuration
        package.numbering_configuration = document.numbering_configuration

        # Serialize main document
        package.raw_document_xml = document.to_xml(encoding: 'UTF-8')

        # Generate ZIP content
        zip_content = package.to_zip_content

        # Add required OOXML infrastructure files
        add_required_files(zip_content)

        # Package and save
        packager = Infrastructure::ZipPackager.new
        packager.package(zip_content, path)
      end

      # Save package to file
      #
      # @param path [String] Output path
      def to_file(path)

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
          content['word/styles.xml'] =
            styles_configuration.to_xml(encoding: 'UTF-8')
        end

        if numbering_configuration
          content['word/numbering.xml'] =
            numbering_configuration.to_xml(encoding: 'UTF-8')
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

      # Add required OOXML files for a valid DOCX package
      #
      # @param zip_content [Hash] The ZIP content hash
      # @return [void]
      def self.add_required_files(zip_content)
        # Add [Content_Types].xml if not present
        unless zip_content['[Content_Types].xml']
          zip_content['[Content_Types].xml'] =
            ContentTypes.generate.to_xml(declaration: true)
        end

        # Add _rels/.rels if not present
        unless zip_content['_rels/.rels']
          zip_content['_rels/.rels'] =
            Relationships::Relationships.generate_package_rels.to_xml(declaration: true)
        end

        # Add word/_rels/document.xml.rels if not present
        return if zip_content['word/_rels/document.xml.rels']

        zip_content['word/_rels/document.xml.rels'] =
          Relationships::Relationships.generate_document_rels.to_xml(
            declaration: true
          )
      end

      private_class_method :add_required_files
    end
  end
end
