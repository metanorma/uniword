# frozen_string_literal: true

require 'lutaml/model'
# Note: ContentTypes and Relationships classes are autoloaded via lib/uniword.rb
# No require_relative needed - the spec uses require 'uniword' which sets up autoloads
# Theme, StylesConfiguration, NumberingConfiguration, Document are autoloaded via lib/uniword.rb

module Uniword
  module Ooxml
    # DOCX Package - Complete OOXML package model
    #
    # Represents the entire .docx file structure as a lutaml-model object.
    # Each XML file within the ZIP is a separate lutaml-model class.
    #
    # This is the CORRECT OOP approach:
    # - ONE model class for the container (DocxPackage)
    # - Each XML part is a proper model attribute (content_types, document, styles, etc.)
    # - No serializer/deserializer anti-pattern
    #
    # @example Load DOCX
    #   package = DocxPackage.from_file('document.docx')
    #   package.core_properties.title = 'New Title'
    #   package.to_file('output.docx')
    #
    # @example Access document content
    #   package = DocxPackage.from_file('document.docx')
    #   package.document.body.paragraphs.each { |p| puts p.text }
    class DocxPackage < Lutaml::Model::Serializable
      # === Package Structure (OOXML Part 2: OPC) ===
      # Content Types ([Content_Types].xml)
      attribute :content_types, Uniword::ContentTypes::Types

      # Package-level relationships (_rels/.rels)
      attribute :package_rels, Relationships::PackageRelationships

      # === Document Properties (docProps/) ===
      # Core document metadata (docProps/core.xml)
      attribute :core_properties, CoreProperties

      # Extended application properties (docProps/app.xml)
      attribute :app_properties, AppProperties

      # === Document Parts (word/) ===
      # Main document content (word/document.xml)
      attribute :document, Uniword::Wordprocessingml::DocumentRoot

      # Document styles (word/styles.xml)
      attribute :styles, Uniword::Wordprocessingml::StylesConfiguration

      # Document numbering (word/numbering.xml)
      attribute :numbering, Uniword::Wordprocessingml::NumberingConfiguration

      # Document settings (word/settings.xml)
      attribute :settings, Uniword::Wordprocessingml::Settings

      # Document font table (word/fontTable.xml)
      attribute :font_table, Uniword::Wordprocessingml::FontTable

      # Document web settings (word/webSettings.xml)
      attribute :web_settings, Uniword::Wordprocessingml::WebSettings

      # Document-level relationships (word/_rels/document.xml.rels)
      attribute :document_rels, Relationships::PackageRelationships

      # === Theme (word/theme/) ===
      # Document theme (word/theme/theme1.xml)
      attribute :theme, Drawingml::Theme

      # Theme-level relationships (word/theme/_rels/theme1.xml.rels)
      attribute :theme_rels, Relationships::PackageRelationships

      # Load DOCX package from file
      #
      # @param path [String] Path to .docx file
      # @return [DocxPackage] Package with all parts loaded
      def self.from_file(path)
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

        # Parse Content Types
        if zip_content['[Content_Types].xml']
          package.content_types = Uniword::ContentTypes::Types.from_xml(
            zip_content['[Content_Types].xml']
          )
        end

        # Parse Package Relationships
        if zip_content['_rels/.rels']
          package.package_rels = Relationships::PackageRelationships.from_xml(
            zip_content['_rels/.rels']
          )
        end

        # Parse Document Properties
        if zip_content['docProps/core.xml']
          package.core_properties = CoreProperties.from_xml(
            zip_content['docProps/core.xml']
          )
        end

        if zip_content['docProps/app.xml']
          package.app_properties = AppProperties.from_xml(
            zip_content['docProps/app.xml']
          )
        end

        # Parse Document Parts
        if zip_content['word/document.xml']
          package.document = Uniword::Wordprocessingml::DocumentRoot.from_xml(
            zip_content['word/document.xml']
          )
        end

        if zip_content['word/styles.xml']
          package.styles = Uniword::Wordprocessingml::StylesConfiguration.from_xml(
            zip_content['word/styles.xml']
          )
        end

        if zip_content['word/numbering.xml']
          package.numbering = Uniword::Wordprocessingml::NumberingConfiguration.from_xml(
            zip_content['word/numbering.xml']
          )
        end

        if zip_content['word/settings.xml']
          package.settings = Uniword::Wordprocessingml::Settings.from_xml(
            zip_content['word/settings.xml']
          )
        end

        if zip_content['word/fontTable.xml']
          package.font_table = Uniword::Wordprocessingml::FontTable.from_xml(
            zip_content['word/fontTable.xml']
          )
        end

        if zip_content['word/webSettings.xml']
          package.web_settings = Uniword::Wordprocessingml::WebSettings.from_xml(
            zip_content['word/webSettings.xml']
          )
        end

        if zip_content['word/_rels/document.xml.rels']
          package.document_rels = Relationships::PackageRelationships.from_xml(
            zip_content['word/_rels/document.xml.rels']
          )
        end

        # Parse Theme
        if zip_content['word/theme/theme1.xml']
          package.theme = Drawingml::Theme.from_xml(
            zip_content['word/theme/theme1.xml']
          )
        end

        if zip_content['word/theme/_rels/theme1.xml.rels']
          package.theme_rels = Relationships::PackageRelationships.from_xml(
            zip_content['word/theme/_rels/theme1.xml.rels']
          )
        end

        package
      end

      # Save document to file (class method for DocumentWriter compatibility)
      #
      # @param document [DocumentRoot] The document to save
      # @param path [String] Output path
      def self.to_file(document, path)
        package = new
        package.document = document
        # Copy parts from document for round-trip preservation
        copy_document_parts_to_package(document, package)
        # Initialize minimal required parts for a valid DOCX
        package.content_types ||= minimal_content_types
        package.package_rels ||= minimal_package_rels
        package.document_rels ||= minimal_document_rels
        package.to_file(path)
      end

      # Copy parts from document to package for round-trip preservation
      #
      # @param document [DocumentRoot] The source document
      # @param package [DocxPackage] The target package
      # @return [void]
      def self.copy_document_parts_to_package(document, package)
        return unless document.is_a?(Uniword::Wordprocessingml::DocumentRoot)

        package.styles = document.styles_configuration if document.styles_configuration
        package.numbering = document.numbering_configuration if document.numbering_configuration
        package.settings = document.settings if document.settings
        package.font_table = document.font_table if document.font_table
        package.web_settings = document.web_settings if document.web_settings
        package.theme = document.theme if document.theme
        package.core_properties = document.core_properties if document.core_properties
        package.app_properties = document.app_properties if document.app_properties
        package.document_rels = document.document_rels if document.document_rels
        package.theme_rels = document.theme_rels if document.theme_rels
      end

      # Create minimal content types for a valid DOCX
      def self.minimal_content_types
        ct = Uniword::ContentTypes::Types.new
        # Add default entries
        ct.defaults ||= []
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: 'rels',
          content_type: 'application/vnd.openxmlformats-package.relationships+xml'
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: 'xml',
          content_type: 'application/xml'
        )
        # Add required overrides
        ct.overrides ||= []
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: '/word/document.xml',
          content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml'
        )
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: '/word/styles.xml',
          content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml'
        )
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: '/word/fontTable.xml',
          content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml'
        )
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: '/word/settings.xml',
          content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml'
        )
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: '/word/webSettings.xml',
          content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.webSettings+xml'
        )
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: '/word/numbering.xml',
          content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.numbering+xml'
        )
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: '/docProps/app.xml',
          content_type: 'application/vnd.openxmlformats-officedocument.extended-properties+xml'
        )
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: '/docProps/core.xml',
          content_type: 'application/vnd.openxmlformats-package.core-properties+xml'
        )
        ct
      end

      # Create minimal package relationships for a valid DOCX
      def self.minimal_package_rels
        rels = Relationships::PackageRelationships.new
        rels.relationships ||= []
        rels.relationships << Relationships::Relationship.new(
          id: 'rId1',
          type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument',
          target: 'word/document.xml'
        )
        rels.relationships << Relationships::Relationship.new(
          id: 'rId2',
          type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties',
          target: 'docProps/app.xml'
        )
        rels.relationships << Relationships::Relationship.new(
          id: 'rId3',
          type: 'http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties',
          target: 'docProps/core.xml'
        )
        rels
      end

      # Create minimal document relationships for a valid DOCX
      def self.minimal_document_rels
        rels = Relationships::PackageRelationships.new
        rels.relationships ||= []
        rels.relationships << Relationships::Relationship.new(
          id: 'rId1',
          type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles',
          target: 'styles.xml'
        )
        rels.relationships << Relationships::Relationship.new(
          id: 'rId2',
          type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/fontTable',
          target: 'fontTable.xml'
        )
        rels.relationships << Relationships::Relationship.new(
          id: 'rId3',
          type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings',
          target: 'settings.xml'
        )
        rels.relationships << Relationships::Relationship.new(
          id: 'rId4',
          type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/webSettings',
          target: 'webSettings.xml'
        )
        rels.relationships << Relationships::Relationship.new(
          id: 'rId5',
          type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/numbering',
          target: 'numbering.xml'
        )
        rels
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

        # Serialize Content Types
        content['[Content_Types].xml'] = content_types.to_xml(
          encoding: 'UTF-8', declaration: true
        ) if content_types

        # Serialize Package Relationships
        content['_rels/.rels'] = package_rels.to_xml(
          encoding: 'UTF-8', declaration: true
        ) if package_rels

        # Serialize Document Properties
        content['docProps/core.xml'] = core_properties.to_xml(
          encoding: 'UTF-8', prefix: false
        ) if core_properties

        content['docProps/app.xml'] = app_properties.to_xml(
          encoding: 'UTF-8', prefix: false
        ) if app_properties

        # Serialize Document Parts
        content['word/document.xml'] = document.to_xml(
          encoding: 'UTF-8', prefix: true, fix_boolean_elements: true
        ) if document

        content['word/styles.xml'] = styles.to_xml(
          encoding: 'UTF-8', fix_boolean_elements: true
        ) if styles

        content['word/numbering.xml'] = numbering.to_xml(
          encoding: 'UTF-8', fix_boolean_elements: true
        ) if numbering

        content['word/settings.xml'] = settings.to_xml(
          encoding: 'UTF-8'
        ) if settings

        content['word/fontTable.xml'] = font_table.to_xml(
          encoding: 'UTF-8'
        ) if font_table

        content['word/webSettings.xml'] = web_settings.to_xml(
          encoding: 'UTF-8'
        ) if web_settings

        content['word/_rels/document.xml.rels'] = document_rels.to_xml(
          encoding: 'UTF-8', declaration: true
        ) if document_rels

        # Serialize Theme
        content['word/theme/theme1.xml'] = theme.to_xml(
          encoding: 'UTF-8'
        ) if theme

        content['word/theme/_rels/theme1.xml.rels'] = theme_rels.to_xml(
          encoding: 'UTF-8', declaration: true
        ) if theme_rels

        content
      end

      # Delegate common DocumentRoot methods for API compatibility
      # This allows code using Uniword.load() to work with DocxPackage seamlessly

      # Get all paragraphs from the document body
      #
      # @return [Array<Paragraph>] All paragraphs
      def paragraphs
        document&.paragraphs || []
      end

      # Get all tables from the document body
      #
      # @return [Array<Table>] All tables
      def tables
        document&.tables || []
      end

      # Get the document body
      #
      # @return [Body, nil] The document body
      def body
        document&.body
      end

      # Get document text content
      #
      # @return [String] Combined text from all paragraphs
      def text
        document&.text || ''
      end

      # Get document body paragraphs as enumerable
      #
      # @return [Enumerator, Array<Paragraph>] Paragraph enumerator
      def each_paragraph(&block)
        paragraphs.each(&block)
      end

      # Alias for to_file (API compatibility)
      alias save to_file

      # Get charts from document
      def charts
        document&.charts || []
      end

      # Get styles configuration from document
      def styles_configuration
        document&.styles_configuration
      end
    end
  end
end
