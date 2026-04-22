# frozen_string_literal: true

require "securerandom"
require "lutaml/model"
require_relative "reconciler"
require_relative "package_defaults"
require_relative "package_serialization"

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
      include PackageDefaults
      include PackageSerialization

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
      attr_accessor :chart_parts, :bibliography_sources, :profile

      # Load DOCX package from file
      #
      # @param path [String] Path to .docx file
      # @return [Package] Package with all parts loaded
      def self.from_file(path)
        extractor = Infrastructure::ZipExtractor.new
        zip_content = extractor.extract(path)
        from_zip_content(zip_content, path)
      end

      # Create package from extracted ZIP content
      #
      # @param zip_content [Hash] Extracted ZIP files
      # @param zip_path [String, nil] Original ZIP path for binary re-extraction
      # @return [Package] Package object
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

            props_path = "customXml/itemProps#{index}.xml"
            item[:props_xml] = zip_content[props_path] if zip_content[props_path]

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
          package.document_rels = Ooxml::Relationships::PackageRelationships.from_xml(
            zip_content["word/_rels/document.xml.rels"]
          )
        end

        # Parse Theme
        if zip_content["word/theme/theme1.xml"]
          package.theme = Drawingml::Theme.from_xml(
            zip_content["word/theme/theme1.xml"]
          )

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
        chart_files = zip_content.keys.grep(%r{^word/charts/chart\d+\.xml$})
        if chart_files.any? && package.document_rels
          package.document.chart_parts ||= {}
          chart_files.each do |chart_path|
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
        extract_image_parts(zip_content, package, zip_path)

        package
      end

      # Extract image files from word/media/ directory in DOCX
      #
      # @param zip_content [Hash] Extracted ZIP content (may have corrupted binary)
      # @param package [Package] Package to populate
      # @param zip_path [String, nil] Original ZIP path for binary re-extraction
      def self.extract_image_parts(zip_content, package, zip_path = nil)
        return unless package.document

        media_files = zip_content.keys.grep(%r{^word/media/.+$})
        return if media_files.empty?

        package.document.image_parts ||= {}

        media_files.each do |media_path|
          filename = File.basename(media_path)
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

          r_id = "rIdImg#{package.document.image_parts.size + 1}"

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
      def self.read_binary_from_zip(zip_path, entry_path)
        require "zip"
        Zip::File.open(zip_path) do |zip_file|
          entry = zip_file.find_entry(entry_path)
          return nil unless entry

          entry.get_input_stream.read
        end
      end

      # Save document to file (class method for DocumentWriter compatibility)
      def self.to_file(document, path)
        package = new
        package.document = document
        copy_document_parts_to_package(document, package)
        package.content_types ||= minimal_content_types
        package.package_rels ||= minimal_package_rels
        package.document_rels ||= minimal_document_rels
        package.settings ||= Uniword::Wordprocessingml::Settings.new
        package.font_table ||= Uniword::Wordprocessingml::FontTable.new
        package.web_settings ||= Uniword::Wordprocessingml::WebSettings.new
        package.to_file(path)
      end

      # Extract media files from word/theme/media/ directory
      def self.extract_theme_media(zip_content)
        media = {}

        zip_content.each_key do |file_path|
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

      # Save package to file
      def to_file(path)
        zip_content = to_zip_content
        packager = Infrastructure::ZipPackager.new
        packager.package(zip_content, path)
      end

      # Generate ZIP content hash
      def to_zip_content
        content = {}

        self.content_types ||= self.class.minimal_content_types
        self.package_rels ||= self.class.minimal_package_rels
        self.document_rels ||= self.class.minimal_document_rels

        self.settings ||= Uniword::Wordprocessingml::Settings.new
        self.font_table ||= Uniword::Wordprocessingml::FontTable.new
        self.web_settings ||= Uniword::Wordprocessingml::WebSettings.new

        Reconciler.new(self, profile: profile).reconcile

        inject_part_relationships(content, content_types, package_rels, document_rels)
        serialize_package_parts(content, content_types, package_rels, document_rels)

        content
      end

      # Delegate common DocumentRoot methods for API compatibility

      def paragraphs
        document&.paragraphs || []
      end

      def tables
        document&.tables || []
      end

      def body
        document&.body
      end

      def text
        document&.text || ""
      end

      def each_paragraph(&)
        paragraphs.each(&)
      end

      alias save to_file

      def charts
        document&.charts || []
      end

      def styles_configuration
        document&.styles_configuration
      end

      # Find the main document path from package relationships
      def self.find_main_document_path(package_rels)
        return nil unless package_rels&.relationships

        rel = package_rels.relationships.find do |r|
          r.type.to_s.include?("officeDocument/2006/relationships/officeDocument")
        end
        return nil unless rel&.target

        path = rel.target.dup
        path.sub!(%r{^/}, "")
        path
      end

      # Find the document relationships path from the main document path
      def self.find_document_rels_path(doc_path)
        return nil unless doc_path

        dir = File.dirname(doc_path)
        basename = File.basename(doc_path)
        File.join(dir, "_rels", "#{basename}.rels")
      end
    end
  end
end
