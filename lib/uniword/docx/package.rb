# frozen_string_literal: true

require "securerandom"
require "lutaml/model"
require_relative "reconciler"

module Uniword
  module Docx
    # DOCX Package - Complete DOCX file format model
    #
    # Represents the entire .docx file structure as a lutaml-model object.
    # Each XML file within the ZIP is a separate lutaml-model class.
    #
    # A DOCX package CONTAINS OOXML markup wrapped in an OPC ZIP container.
    # This class lives in Uniword::Docx, not Uniword::Ooxml, because
    # DOCX is a file format that uses OOXML, not the other way around.
    #
    # @example Load DOCX
    #   package = Package.from_file('document.docx')
    #   package.core_properties.title = 'New Title'
    #   package.to_file('output.docx')
    #
    # @example Access document content
    #   package = Package.from_file('document.docx')
    #   package.document.body.paragraphs.each { |p| puts p.text }
    class Package < Lutaml::Model::Serializable
      # === Package Structure (OOXML Part 2: OPC) ===
      # Content Types ([Content_Types].xml)
      attribute :content_types, Uniword::ContentTypes::Types

      # Package-level relationships (_rels/.rels)
      attribute :package_rels, Ooxml::Relationships::PackageRelationships

      # === Document Properties (docProps/) ===
      # Core document metadata (docProps/core.xml)
      attribute :core_properties, Ooxml::CoreProperties

      # Extended application properties (docProps/app.xml)
      attribute :app_properties, Ooxml::AppProperties

      # Custom document properties (docProps/custom.xml)
      attribute :custom_properties, Ooxml::CustomProperties

      # Custom XML data items (customXml/item*.xml)
      attr_accessor :custom_xml_items

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
      attribute :document_rels, Ooxml::Relationships::PackageRelationships

      # === Theme (word/theme/) ===
      # Document theme (word/theme/theme1.xml)
      attribute :theme, Drawingml::Theme

      # Theme-level relationships (word/theme/_rels/theme1.xml.rels)
      attribute :theme_rels, Ooxml::Relationships::PackageRelationships

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
        from_zip_content(zip_content, path)
      end

      # Create package from extracted ZIP content
      #
      # @param zip_content [Hash] Extracted ZIP files
      # @param zip_path [String, nil] Original ZIP path for binary re-extraction
      # @return [DocxPackage] Package object
      def self.from_zip_content(zip_content, zip_path = nil)
        package = new

        # Parse Content Types
        if zip_content["[Content_Types].xml"]
          package.content_types = Uniword::ContentTypes::Types.from_xml(
            zip_content["[Content_Types].xml"]
          )
        end

        # Parse Package Relationships
        if zip_content["_rels/.rels"]
          package.package_rels = Ooxml::Relationships::PackageRelationships.from_xml(
            zip_content["_rels/.rels"]
          )
        end

        # Find the main document path from officeDocument relationship
        main_doc_path = find_main_document_path(package.package_rels)
        main_doc_rels_path = find_document_rels_path(main_doc_path)

        # Parse Document Properties
        if zip_content["docProps/core.xml"]
          package.core_properties = Ooxml::CoreProperties.from_xml(
            zip_content["docProps/core.xml"]
          )
        end

        if zip_content["docProps/app.xml"]
          package.app_properties = Ooxml::AppProperties.from_xml(
            zip_content["docProps/app.xml"]
          )
        end

        # Parse Custom Properties
        if zip_content["docProps/custom.xml"]
          package.custom_properties = Ooxml::CustomProperties.from_xml(
            zip_content["docProps/custom.xml"]
          )
        end

        # Parse Custom XML Data items (customXml/item*.xml)
        custom_xml_files = zip_content.keys.grep(%r{^customXml/item(\d+)\.xml$})
        if custom_xml_files.any?
          package.custom_xml_items = []
          custom_xml_files.sort_by { |f| f[/item(\d+)/, 1].to_i }.each do |item_path|
            index = item_path[/item(\d+)/, 1].to_i
            item = {
              index: index,
              xml_content: zip_content[item_path]
            }

            # Parse itemProps
            props_path = "customXml/itemProps#{index}.xml"
            item[:props_xml] = zip_content[props_path] if zip_content[props_path]

            # Parse item relationships
            rels_path = "customXml/_rels/item#{index}.xml.rels"
            item[:rels_xml] = zip_content[rels_path] if zip_content[rels_path]

            package.custom_xml_items << item
          end
        end

        # Parse Document Parts - use dynamic path from package relationships
        if main_doc_path && zip_content[main_doc_path]
          package.document = Uniword::Wordprocessingml::DocumentRoot.from_xml(
            zip_content[main_doc_path]
          )
        elsif zip_content["word/document.xml"]
          # Fallback to standard path
          package.document = Uniword::Wordprocessingml::DocumentRoot.from_xml(
            zip_content["word/document.xml"]
          )
        end

        if zip_content["word/styles.xml"]
          package.styles = Uniword::Wordprocessingml::StylesConfiguration.from_xml(
            zip_content["word/styles.xml"]
          )
        end

        if zip_content["word/numbering.xml"]
          package.numbering = Uniword::Wordprocessingml::NumberingConfiguration.from_xml(
            zip_content["word/numbering.xml"]
          )
        end

        if zip_content["word/settings.xml"]
          package.settings = Uniword::Wordprocessingml::Settings.from_xml(
            zip_content["word/settings.xml"]
          )
        end

        if zip_content["word/fontTable.xml"]
          package.font_table = Uniword::Wordprocessingml::FontTable.from_xml(
            zip_content["word/fontTable.xml"]
          )
        end

        if zip_content["word/webSettings.xml"]
          package.web_settings = Uniword::Wordprocessingml::WebSettings.from_xml(
            zip_content["word/webSettings.xml"]
          )
        end

        # Parse document relationships - use dynamic path based on main document
        if main_doc_rels_path && zip_content[main_doc_rels_path]
          package.document_rels = Ooxml::Relationships::PackageRelationships.from_xml(
            zip_content[main_doc_rels_path]
          )
        elsif zip_content["word/_rels/document.xml.rels"]
          # Fallback to standard path
          package.document_rels = Ooxml::Relationships::PackageRelationships.from_xml(
            zip_content["word/_rels/document.xml.rels"]
          )
        end

        # Parse Theme
        if zip_content["word/theme/theme1.xml"]
          package.theme = Drawingml::Theme.from_xml(
            zip_content["word/theme/theme1.xml"]
          )

          # Extract theme media files from word/theme/media/ directory
          theme_media = extract_theme_media(zip_content)
          package.theme.media_files = theme_media if theme_media.any?
        end

        if zip_content["word/theme/_rels/theme1.xml.rels"]
          package.theme_rels = Ooxml::Relationships::PackageRelationships.from_xml(
            zip_content["word/theme/_rels/theme1.xml.rels"]
          )
        end

        # Parse Footnotes
        if zip_content["word/footnotes.xml"]
          package.footnotes = Uniword::Wordprocessingml::Footnotes.from_xml(
            zip_content["word/footnotes.xml"]
          )
        end

        # Parse Endnotes
        if zip_content["word/endnotes.xml"]
          package.endnotes = Uniword::Wordprocessingml::Endnotes.from_xml(
            zip_content["word/endnotes.xml"]
          )
        end

        # Parse Chart parts
        # Find all word/charts/chart*.xml files and match with relationships
        chart_files = zip_content.keys.grep(%r{^word/charts/chart\d+\.xml$})
        if chart_files.any? && package.document_rels
          package.document.chart_parts ||= {}
          chart_files.each do |chart_path|
            # Find the relationship that points to this chart
            chart_target = chart_path.sub("word/", "")
            rel = package.document_rels.relationships.find do |r|
              r.target == chart_target &&
                r.type.to_s.include?("officeDocument/2006/relationships/chart")
            end
            next unless rel

            package.document.chart_parts[rel.id] = {
              xml: zip_content[chart_path],
              target: chart_target
            }
          end
        end

        # Extract image parts from word/media/ directory
        # Pass zip_path for binary re-extraction to avoid UTF-8 corruption
        extract_image_parts(zip_content, package, zip_path)

        package
      end

      # Extract image files from word/media/ directory in DOCX
      #
      # @param zip_content [Hash] Extracted ZIP content (may have corrupted binary)
      # @param package [DocxPackage] Package to populate
      # @param zip_path [String, nil] Original ZIP path for binary re-extraction
      def self.extract_image_parts(zip_content, package, zip_path = nil)
        return unless package.document

        # Find all media files
        media_files = zip_content.keys.grep(%r{^word/media/.+$})
        return if media_files.empty?

        package.document.image_parts ||= {}

        media_files.each do |media_path|
          # Get filename for the key
          filename = File.basename(media_path)
          # Determine content type from extension
          ext = File.extname(filename).delete(".").downcase
          content_type = case ext
                         when "jpg", "jpeg" then "image/jpeg"
                         when "png" then "image/png"
                         when "gif" then "image/gif"
                         when "bmp" then "image/bmp"
                         when "tiff", "tif" then "image/tiff"
                         when "svg" then "image/svg+xml"
                         else "image/#{ext}"
                         end

          # Generate a unique rId for this image
          r_id = "rIdImg#{package.document.image_parts.size + 1}"

          # Re-extract binary data directly from ZIP to avoid UTF-8 corruption
          # Use zip_path if available, otherwise fall back to corrupted content
          binary_data = if zip_path
                          read_binary_from_zip(zip_path, media_path)
                        else
                          zip_content[media_path]
                        end

          package.document.image_parts[r_id] = {
            data: binary_data,
            target: "media/#{filename}",
            content_type: content_type
          }
        end
      end

      # Read binary data directly from ZIP file without UTF-8 encoding
      #
      # @param zip_path [String] Path to ZIP file
      # @param entry_path [String] Path within ZIP
      # @return [String] Binary data
      def self.read_binary_from_zip(zip_path, entry_path)
        require "zip"
        Zip::File.open(zip_path) do |zip_file|
          entry = zip_file.find_entry(entry_path)
          return nil unless entry

          entry.get_input_stream.read
        end
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
        package.to_file(path)
      end

      # Copy parts from document to package for round-trip preservation
      #
      # @param document [DocumentRoot] The source document
      # @param package [DocxPackage] The target package
      # @return [void]
      def self.copy_document_parts_to_package(document, package)
        return unless document.is_a?(Uniword::Wordprocessingml::DocumentRoot)

        DOCUMENT_TO_PACKAGE_MAPPINGS.each do |doc_attr, pkg_attr|
          value = document.send(doc_attr)
          package.send(:"#{pkg_attr}=", value) if value
        end

        # Only copy numbering if it was explicitly loaded from the source DOCX
        if document.numbering_configuration_loaded?
          package.numbering = document.numbering_configuration
        end

        package.chart_parts = document.chart_parts if document.chart_parts
        package.custom_xml_items = document.custom_xml_items if document.custom_xml_items
        package.bibliography_sources = document.bibliography_sources if document.bibliography_sources
      end

      # Mapping from DocumentRoot attributes to Package attributes.
      # Only entries where names differ need explicit mapping.
      DOCUMENT_TO_PACKAGE_MAPPINGS = {
        styles_configuration: :styles,
        settings: :settings,
        font_table: :font_table,
        web_settings: :web_settings,
        theme: :theme,
        core_properties: :core_properties,
        app_properties: :app_properties,
        custom_properties: :custom_properties,
        document_rels: :document_rels,
        theme_rels: :theme_rels,
        package_rels: :package_rels,
        content_types: :content_types,
        footnotes: :footnotes,
        endnotes: :endnotes,
      }.freeze

      # Extract media files from word/theme/media/ directory in DOCX
      #
      # @param zip_content [Hash] Extracted ZIP content
      # @return [Hash] filename => MediaFile objects
      def self.extract_theme_media(zip_content)
        media = {}

        zip_content.each_key do |file_path|
          # Match pattern: word/theme/media/{filename}
          next unless file_path =~ %r{^word/theme/media/(.+)$}

          filename = Regexp.last_match(1)
          media[filename] = Uniword::Themes::MediaFile.new(
            filename: filename,
            content: zip_content[file_path],
            source_path: file_path
          )
        end

        media
      end

      # Create minimal content types for a valid DOCX
      def self.minimal_content_types
        ct = Uniword::ContentTypes::Types.new
        # Add default entries
        ct.defaults ||= []
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: "rels",
          content_type: "application/vnd.openxmlformats-package.relationships+xml"
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: "xml",
          content_type: "application/xml"
        )
        # Image extension defaults
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: "png",
          content_type: "image/png"
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: "jpeg",
          content_type: "image/jpeg"
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: "jpg",
          content_type: "image/jpeg"
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: "gif",
          content_type: "image/gif"
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: "bmp",
          content_type: "image/bmp"
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: "tif",
          content_type: "image/tiff"
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: "tiff",
          content_type: "image/tiff"
        )
        ct.defaults << Uniword::ContentTypes::Default.new(
          extension: "svg",
          content_type: "image/svg+xml"
        )
        # Add required overrides
        ct.overrides ||= []
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: "/word/document.xml",
          content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"
        )
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: "/word/styles.xml",
          content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"
        )
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: "/word/fontTable.xml",
          content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml"
        )
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: "/word/settings.xml",
          content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"
        )
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: "/word/webSettings.xml",
          content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.webSettings+xml"
        )
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: "/docProps/app.xml",
          content_type: "application/vnd.openxmlformats-officedocument.extended-properties+xml"
        )
        ct.overrides << Uniword::ContentTypes::Override.new(
          part_name: "/docProps/core.xml",
          content_type: "application/vnd.openxmlformats-package.core-properties+xml"
        )
        ct
      end

      # Create minimal package relationships for a valid DOCX
      def self.minimal_package_rels
        rels = Ooxml::Relationships::PackageRelationships.new
        rels.relationships ||= []
        rels.relationships << Ooxml::Relationships::Relationship.new(
          id: "rId1",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument",
          target: "word/document.xml"
        )
        rels.relationships << Ooxml::Relationships::Relationship.new(
          id: "rId2",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties",
          target: "docProps/app.xml"
        )
        rels.relationships << Ooxml::Relationships::Relationship.new(
          id: "rId3",
          type: "http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties",
          target: "docProps/core.xml"
        )
        rels
      end

      # Create minimal document relationships for a valid DOCX
      def self.minimal_document_rels
        rels = Ooxml::Relationships::PackageRelationships.new
        rels.relationships ||= []
        rels.relationships << Ooxml::Relationships::Relationship.new(
          id: "rId1",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles",
          target: "styles.xml"
        )
        rels.relationships << Ooxml::Relationships::Relationship.new(
          id: "rId2",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/fontTable",
          target: "fontTable.xml"
        )
        rels.relationships << Ooxml::Relationships::Relationship.new(
          id: "rId3",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings",
          target: "settings.xml"
        )
        rels.relationships << Ooxml::Relationships::Relationship.new(
          id: "rId4",
          type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/webSettings",
          target: "webSettings.xml"
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

        # --- Reconcile: enforce DOCX-level invariants before serialization ---
        Reconciler.new(self).reconcile

        # --- Pre-serialization: inject rels and content types ---
        inject_part_relationships(content, content_types, package_rels, document_rels)

        # --- Serialize all parts ---
        serialize_package_parts(content, content_types, package_rels, document_rels)

        content
      end

      # Inject content types and relationships for all package parts
      def inject_part_relationships(content, content_types, package_rels, document_rels)
        inject_image_parts(content, content_types, document_rels)
        inject_chart_parts(content, content_types, document_rels)
        inject_bibliography(content_types, document_rels)
        inject_custom_properties(content_types, package_rels)
        inject_custom_xml(content_types)
        inject_headers(content_types, document_rels)
        inject_footers(content_types, document_rels)
        inject_header_footer_parts(content_types, document_rels)
        inject_notes(content_types, document_rels)
      end

      private :inject_part_relationships

      def inject_image_parts(content, content_types, document_rels)
        return unless document&.image_parts && !document.image_parts.empty?

        document.image_parts.each_value do |image_data|
          ext = File.extname(image_data[:target]).delete(".")
          next if content_types.defaults.any? { |d| d.extension == ext }

          content_types.defaults << Uniword::ContentTypes::Default.new(
            extension: ext, content_type: image_data[:content_type]
          )
        end

        document.image_parts.each do |r_id, image_data|
          content["word/#{image_data[:target]}"] = image_data[:data]
          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: r_id,
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image",
            target: image_data[:target]
          )
        end
      end

      private :inject_image_parts

      def inject_chart_parts(content, content_types, document_rels)
        return unless document&.chart_parts && !document.chart_parts.empty?

        unless content_types.overrides.any? { |o| o.part_name&.start_with?("/word/charts/") }
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/charts/chart1.xml",
            content_type: "application/vnd.openxmlformats-officedocument.drawingml.chart+xml"
          )
        end

        document.chart_parts.each do |r_id, chart_data|
          content["word/#{chart_data[:target]}"] = chart_data[:xml]
          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: r_id,
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/chart",
            target: chart_data[:target]
          )
        end
      end

      private :inject_chart_parts

      def inject_bibliography(content_types, document_rels)
        return unless document&.bibliography_sources

        unless content_types.overrides.any? { |o| o.part_name == "/word/sources.xml" }
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/sources.xml",
            content_type: "application/vnd.openxmlformats-officedocument.bibliography+xml"
          )
        end

        unless document_rels.relationships.any? { |r| r.target == "sources.xml" }
          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: "rIdSrc#{SecureRandom.hex(4)}",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/bibliography",
            target: "sources.xml"
          )
        end
      end

      private :inject_bibliography

      def inject_custom_properties(content_types, package_rels)
        return unless custom_properties && !custom_properties.properties.empty?

        unless content_types.overrides.any? { |o| o.part_name == "/docProps/custom.xml" }
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/docProps/custom.xml",
            content_type: "application/vnd.openxmlformats-officedocument.custom-properties+xml"
          )
        end

        unless package_rels.relationships.any? do |r|
          r.type.to_s.include?("officeDocument/2006/relationships/custom-properties")
        end
          package_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: "rIdCustProps",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/custom-properties",
            target: "docProps/custom.xml"
          )
        end
      end

      private :inject_custom_properties

      def inject_custom_xml(content_types)
        return unless custom_xml_items && !custom_xml_items.empty?

        custom_xml_items.each do |item|
          idx = item[:index]
          next if content_types.overrides.any? { |o| o.part_name == "/customXml/itemProps#{idx}.xml" }

          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/customXml/itemProps#{idx}.xml",
            content_type: "application/vnd.openxmlformats-officedocument.customXmlProperties+xml"
          )
        end
      end

      private :inject_custom_xml

      def inject_headers(content_types, document_rels)
        return unless document&.headers && !document.headers.empty?

        counter = 0
        document.headers.each_key do |type|
          counter += 1
          r_id = "rIdHeader#{counter}"

          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/header#{counter}.xml",
            content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml"
          )

          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: r_id,
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/header",
            target: "header#{counter}.xml"
          )

          wire_header_reference(type, r_id)
        end
      end

      private :inject_headers

      def inject_footers(content_types, document_rels)
        return unless document&.footers && !document.footers.empty?

        counter = 0
        document.footers.each_key do |type|
          counter += 1
          r_id = "rIdFooter#{counter}"

          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/footer#{counter}.xml",
            content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml"
          )

          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: r_id,
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer",
            target: "footer#{counter}.xml"
          )

          wire_footer_reference(type, r_id)
        end
      end

      private :inject_footers

      def inject_header_footer_parts(content_types, document_rels)
        return unless document&.header_footer_parts && !document.header_footer_parts.empty?

        document.header_footer_parts.each do |part|
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/#{part[:target]}",
            content_type: part[:content_type]
          )

          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: part[:r_id],
            type: part[:rel_type],
            target: part[:target]
          )
        end
      end

      private :inject_header_footer_parts

      def inject_notes(content_types, document_rels)
        if footnotes
          unless content_types.overrides.any? { |o| o.part_name == "/word/footnotes.xml" }
            content_types.overrides << Uniword::ContentTypes::Override.new(
              part_name: "/word/footnotes.xml",
              content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml"
            )
          end

          unless document_rels.relationships.any? { |r| r.target == "footnotes.xml" }
            document_rels.relationships << Ooxml::Relationships::Relationship.new(
              id: "rIdFootnotes",
              type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footnotes",
              target: "footnotes.xml"
            )
          end
        end

        return unless endnotes

        unless content_types.overrides.any? { |o| o.part_name == "/word/endnotes.xml" }
          content_types.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/endnotes.xml",
            content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.endnotes+xml"
          )
        end

        unless document_rels.relationships.any? { |r| r.target == "endnotes.xml" }
          document_rels.relationships << Ooxml::Relationships::Relationship.new(
            id: "rIdEndnotes",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/endnotes",
            target: "endnotes.xml"
          )
        end
      end

      private :inject_notes

      def wire_header_reference(type, r_id)
        return unless document&.body

        sect_pr = document.body.section_properties ||= Wordprocessingml::SectionProperties.new
        existing = sect_pr.header_references&.find { |r| r.type == type }
        if existing
          existing.r_id = r_id
        else
          sect_pr.header_references << Wordprocessingml::HeaderReference.new(type: type, r_id: r_id)
        end
      end

      private :wire_header_reference

      def wire_footer_reference(type, r_id)
        return unless document&.body

        sect_pr = document.body.section_properties ||= Wordprocessingml::SectionProperties.new
        existing = sect_pr.footer_references&.find { |r| r.type == type }
        if existing
          existing.r_id = r_id
        else
          sect_pr.footer_references << Wordprocessingml::FooterReference.new(type: type, r_id: r_id)
        end
      end

      private :wire_footer_reference

      # Serialize all package parts to XML and add to content hash
      def serialize_package_parts(content, content_types, package_rels, document_rels)
        # Package infrastructure
        content["[Content_Types].xml"] = content_types.to_xml(encoding: "UTF-8", declaration: true)
        content["_rels/.rels"] = package_rels.to_xml(encoding: "UTF-8", declaration: true)

        # Document properties
        if core_properties
          content["docProps/core.xml"] = core_properties.to_xml(encoding: "UTF-8", prefix: false)
        end
        if app_properties
          content["docProps/app.xml"] = app_properties.to_xml(encoding: "UTF-8", prefix: false)
        end
        if custom_properties
          content["docProps/custom.xml"] = custom_properties.to_xml(encoding: "UTF-8", prefix: false)
        end

        # Custom XML data items
        if custom_xml_items && !custom_xml_items.empty?
          custom_xml_items.each do |item|
            idx = item[:index]
            content["customXml/item#{idx}.xml"] = item[:xml_content]
            content["customXml/itemProps#{idx}.xml"] = item[:props_xml] if item[:props_xml]
            content["customXml/_rels/item#{idx}.xml.rels"] = item[:rels_xml] if item[:rels_xml]
          end
        end

        # Document parts
        if document
          content["word/document.xml"] = document.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true)
        end
        content["word/styles.xml"] = styles.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true) if styles
        content["word/numbering.xml"] = numbering.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true) if numbering
        content["word/settings.xml"] = settings.to_xml(encoding: "UTF-8", prefix: true) if settings
        content["word/fontTable.xml"] = font_table.to_xml(encoding: "UTF-8", prefix: true) if font_table
        content["word/webSettings.xml"] = web_settings.to_xml(encoding: "UTF-8", prefix: true) if web_settings
        content["word/_rels/document.xml.rels"] = document_rels.to_xml(encoding: "UTF-8", declaration: true) if document_rels

        # Theme
        content["word/theme/theme1.xml"] = theme.to_xml(encoding: "UTF-8", prefix: true) if theme
        content["word/theme/_rels/theme1.xml.rels"] = theme_rels.to_xml(encoding: "UTF-8", declaration: true) if theme_rels

        # Notes
        content["word/footnotes.xml"] = footnotes.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true) if footnotes
        content["word/endnotes.xml"] = endnotes.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true) if endnotes

        # Bibliography sources
        if document&.bibliography_sources
          content["word/sources.xml"] = document.bibliography_sources.to_xml(encoding: "UTF-8", declaration: true)
        end

        # Headers and footers
        serialize_headers(content)
        serialize_footers(content)
        serialize_header_footer_parts(content)
      end

      private :serialize_package_parts

      def serialize_headers(content)
        return unless document&.headers && !document.headers.empty?

        idx = 0
        document.headers.each_value do |header_obj|
          idx += 1
          content["word/header#{idx}.xml"] = header_obj.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true)
        end
      end

      private :serialize_headers

      def serialize_footers(content)
        return unless document&.footers && !document.footers.empty?

        idx = 0
        document.footers.each_value do |footer_obj|
          idx += 1
          content["word/footer#{idx}.xml"] = footer_obj.to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true)
        end
      end

      private :serialize_footers

      def serialize_header_footer_parts(content)
        return unless document&.header_footer_parts && !document.header_footer_parts.empty?

        document.header_footer_parts.each do |part|
          content["word/#{part[:target]}"] = part[:content].to_xml(encoding: "UTF-8", prefix: true, fix_boolean_elements: true)
        end
      end

      private :serialize_header_footer_parts

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
        document&.text || ""
      end

      # Get document body paragraphs as enumerable
      #
      # @return [Enumerator, Array<Paragraph>] Paragraph enumerator
      def each_paragraph(&)
        paragraphs.each(&)
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

      # Find the main document path from package relationships
      #
      # The officeDocument relationship type is:
      # http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument
      #
      # @param package_rels [PackageRelationships, nil] Parsed package relationships
      # @return [String, nil] Normalized document path (e.g., 'word/document.xml')
      def self.find_main_document_path(package_rels)
        return nil unless package_rels&.relationships

        rel = package_rels.relationships.find do |r|
          r.type.to_s.include?("officeDocument/2006/relationships/officeDocument")
        end
        return nil unless rel&.target

        # Normalize path - strip leading slash if present
        path = rel.target.dup
        path.sub!(%r{^/}, "")
        path
      end

      # Find the document relationships path from the main document path
      #
      # For 'word/document.xml' returns 'word/_rels/document.xml.rels'
      # For 'word/document2.xml' returns 'word/_rels/document2.xml.rels'
      #
      # @param doc_path [String, nil] Main document path
      # @return [String, nil] Document relationships path
      def self.find_document_rels_path(doc_path)
        return nil unless doc_path

        # Extract directory and filename
        dir = File.dirname(doc_path)
        basename = File.basename(doc_path)
        File.join(dir, "_rels", "#{basename}.rels")
      end
    end
  end
end
