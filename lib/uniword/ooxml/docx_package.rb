# frozen_string_literal: true

require 'securerandom'
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

      # === Footnotes and Endnotes (word/) ===
      # Footnotes (word/footnotes.xml)
      attribute :footnotes, Uniword::Wordprocessingml::Footnotes

      # Endnotes (word/endnotes.xml)
      attribute :endnotes, Uniword::Wordprocessingml::Endnotes

      # Non-serialized attributes (DOCX packaging helpers)
      attr_accessor :chart_parts, :bibliography_sources

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

        # Parse Footnotes
        if zip_content['word/footnotes.xml']
          package.footnotes = Uniword::Wordprocessingml::Footnotes.from_xml(
            zip_content['word/footnotes.xml']
          )
        end

        # Parse Endnotes
        if zip_content['word/endnotes.xml']
          package.endnotes = Uniword::Wordprocessingml::Endnotes.from_xml(
            zip_content['word/endnotes.xml']
          )
        end

        # Parse Chart parts
        # Find all word/charts/chart*.xml files and match with relationships
        chart_files = zip_content.keys.select { |k| k.match?(%r{^word/charts/chart\d+\.xml$}) }
        if chart_files.any? && package.document_rels
          package.document.chart_parts ||= {}
          chart_files.each do |chart_path|
            # Find the relationship that points to this chart
            chart_target = chart_path.sub('word/', '')
            rel = package.document_rels.relationships.find do |r|
              r.target == chart_target &&
                r.type.to_s.include?('officeDocument/2006/relationships/chart')
            end
            next unless rel

            package.document.chart_parts[rel.id] = {
              xml: zip_content[chart_path],
              target: chart_target
            }
          end
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
        # Ensure all relationship targets have corresponding parts
        package.settings ||= Uniword::Wordprocessingml::Settings.new
        package.font_table ||= Uniword::Wordprocessingml::FontTable.new
        package.web_settings ||= Uniword::Wordprocessingml::WebSettings.new
        package.footnotes ||= Uniword::Wordprocessingml::Footnotes.new
        package.endnotes ||= Uniword::Wordprocessingml::Endnotes.new
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
        package.package_rels = document.package_rels if document.package_rels
        package.content_types = document.content_types if document.content_types
        package.footnotes = document.footnotes if document.footnotes
        package.endnotes = document.endnotes if document.endnotes
        package.chart_parts = document.chart_parts if document.chart_parts
        package.bibliography_sources = document.bibliography_sources if document.bibliography_sources
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
        # Image extension defaults
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: 'png',
          content_type: 'image/png'
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: 'jpeg',
          content_type: 'image/jpeg'
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: 'jpg',
          content_type: 'image/jpeg'
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: 'gif',
          content_type: 'image/gif'
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: 'bmp',
          content_type: 'image/bmp'
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: 'tif',
          content_type: 'image/tiff'
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: 'tiff',
          content_type: 'image/tiff'
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: 'svg',
          content_type: 'image/svg+xml'
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
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: '/word/footnotes.xml',
          content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml'
        )
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: '/word/endnotes.xml',
          content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.endnotes+xml'
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
        rels.relationships << Relationships::Relationship.new(
          id: 'rId6',
          type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/footnotes',
          target: 'footnotes.xml'
        )
        rels.relationships << Relationships::Relationship.new(
          id: 'rId7',
          type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/endnotes',
          target: 'endnotes.xml'
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

        # Initialize content types and relationships from model attributes
        # or fall back to minimal defaults
        content_types = self.content_types || self.class.minimal_content_types
        package_rels = self.package_rels || self.class.minimal_package_rels
        document_rels = self.document_rels || self.class.minimal_document_rels

        # Ensure all relationship targets have corresponding parts
        self.settings ||= Uniword::Wordprocessingml::Settings.new
        self.font_table ||= Uniword::Wordprocessingml::FontTable.new
        self.web_settings ||= Uniword::Wordprocessingml::WebSettings.new
        self.footnotes ||= Uniword::Wordprocessingml::Footnotes.new
        self.endnotes ||= Uniword::Wordprocessingml::Endnotes.new

        # --- Pre-serialization: inject image/chart/bibliography into content_types and document_rels ---

        # Image parts: add content types and relationships
        if document&.image_parts && !document.image_parts.empty?
          document.image_parts.each_value do |image_data|
            ext = File.extname(image_data[:target]).delete('.')
            unless content_types.defaults.any? { |d| d.extension == ext }
              content_types.defaults << Uniword::ContentTypes::Default.new(
                extension: ext,
                content_type: image_data[:content_type]
              )
            end
          end

          # Image relationships are added after finding unique rIds
          document.image_parts.each do |r_id, image_data|
            content["word/#{image_data[:target]}"] = image_data[:data]
            document_rels.relationships << Relationships::Relationship.new(
              id: r_id,
              type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/image',
              target: image_data[:target]
            )
          end
        end

        # Chart parts: add content type and relationships
        if document&.chart_parts && !document.chart_parts.empty?
          unless content_types.overrides.any? { |o| o.part_name&.start_with?('/word/charts/') }
            content_types.overrides << Uniword::ContentTypes::Override.new(
              part_name: '/word/charts/chart1.xml',
              content_type: 'application/vnd.openxmlformats-officedocument.drawingml.chart+xml'
            )
          end

          document.chart_parts.each do |r_id, chart_data|
            content["word/#{chart_data[:target]}"] = chart_data[:xml]
            document_rels.relationships << Relationships::Relationship.new(
              id: r_id,
              type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/chart',
              target: chart_data[:target]
            )
          end
        end

        # Bibliography sources: add content type and relationship
        if document&.bibliography_sources
          unless content_types.overrides.any? { |o| o.part_name == '/word/sources.xml' }
            content_types.overrides << Uniword::ContentTypes::Override.new(
              part_name: '/word/sources.xml',
              content_type: 'application/vnd.openxmlformats-officedocument.bibliography+xml'
            )
          end

          unless document_rels.relationships.any? { |r| r.target == 'sources.xml' }
            document_rels.relationships << Relationships::Relationship.new(
              id: "rIdSrc#{SecureRandom.hex(4)}",
              type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/bibliography',
              target: 'sources.xml'
            )
          end
        end

        # Headers and footers: inject content types, relationships, section refs
        header_counter = 0
        footer_counter = 0

        if document&.headers && !document.headers.empty?
          document.headers.each do |type, header_obj|
            header_counter += 1
            r_id = "rIdHeader#{header_counter}"

            content_types.overrides << Uniword::ContentTypes::Override.new(
              part_name: "/word/header#{header_counter}.xml",
              content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml'
            )

            document_rels.relationships << Relationships::Relationship.new(
              id: r_id,
              type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/header',
              target: "header#{header_counter}.xml"
            )

            # Wire into section properties
            sect_pr = document.body.section_properties ||= Wordprocessingml::SectionProperties.new
            existing = sect_pr.header_references&.find { |r| r.type == type }
            if existing
              existing.r_id = r_id
            else
              sect_pr.header_references << Wordprocessingml::HeaderReference.new(
                type: type, r_id: r_id
              )
            end
          end
        end

        if document&.footers && !document.footers.empty?
          document.footers.each do |type, footer_obj|
            footer_counter += 1
            r_id = "rIdFooter#{footer_counter}"

            content_types.overrides << Uniword::ContentTypes::Override.new(
              part_name: "/word/footer#{footer_counter}.xml",
              content_type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml'
            )

            document_rels.relationships << Relationships::Relationship.new(
              id: r_id,
              type: 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer',
              target: "footer#{footer_counter}.xml"
            )

            # Wire into section properties
            sect_pr = document.body.section_properties ||= Wordprocessingml::SectionProperties.new
            existing = sect_pr.footer_references&.find { |r| r.type == type }
            if existing
              existing.r_id = r_id
            else
              sect_pr.footer_references << Wordprocessingml::FooterReference.new(
                type: type, r_id: r_id
              )
            end
          end
        end

        # Serialize Content Types
        content['[Content_Types].xml'] = content_types.to_xml(
          encoding: 'UTF-8', declaration: true
        )

        # Serialize Package Relationships
        content['_rels/.rels'] = package_rels.to_xml(
          encoding: 'UTF-8', declaration: true
        )

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

        # Serialize Footnotes
        content['word/footnotes.xml'] = footnotes.to_xml(
          encoding: 'UTF-8', fix_boolean_elements: true
        ) if footnotes

        # Serialize Endnotes
        content['word/endnotes.xml'] = endnotes.to_xml(
          encoding: 'UTF-8', fix_boolean_elements: true
        ) if endnotes

        # Serialize Bibliography Sources
        if document&.bibliography_sources
          content['word/sources.xml'] = document.bibliography_sources.to_xml(
            encoding: 'UTF-8', declaration: true
          )
        end

        # Serialize Headers
        if document&.headers && !document.headers.empty?
          h_idx = 0
          document.headers.each_value do |header_obj|
            h_idx += 1
            content["word/header#{h_idx}.xml"] = header_obj.to_xml(
              encoding: 'UTF-8', prefix: true, fix_boolean_elements: true
            )
          end
        end

        # Serialize Footers
        if document&.footers && !document.footers.empty?
          f_idx = 0
          document.footers.each_value do |footer_obj|
            f_idx += 1
            content["word/footer#{f_idx}.xml"] = footer_obj.to_xml(
              encoding: 'UTF-8', prefix: true, fix_boolean_elements: true
            )
          end
        end

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
