# frozen_string_literal: true

module Uniword
  module Docx
    # Factory methods and defaults for DOCX package construction.
    #
    # Extracted from Package for separation of responsibilities.
    # Included in Package for backward compatibility.
    #
    # @api private
    module PackageDefaults
      def self.included(base)
        base.extend(ClassMethods)
      end

      # Class methods for package construction
      module ClassMethods
        # Copy parts from document to package for round-trip preservation
        def copy_document_parts_to_package(document, package)
          return unless document.is_a?(Uniword::Wordprocessingml::DocumentRoot)

          package.styles = document.styles_configuration if document.styles_configuration
          package.settings = document.settings if document.settings
          package.font_table = document.font_table if document.font_table
          package.web_settings = document.web_settings if document.web_settings
          package.theme = document.theme if document.theme
          package.core_properties = document.core_properties if document.core_properties
          package.app_properties = document.app_properties if document.app_properties
          package.custom_properties = document.custom_properties if document.custom_properties
          package.document_rels = document.document_rels if document.document_rels
          package.theme_rels = document.theme_rels if document.theme_rels
          package.package_rels = document.package_rels if document.package_rels
          package.content_types = document.content_types if document.content_types
          package.footnotes = document.footnotes if document.footnotes
          package.endnotes = document.endnotes if document.endnotes
          package.allocator = document.allocator if document.allocator

          package.numbering = document.numbering_configuration if document.numbering_configuration_loaded?

          package.chart_parts = document.chart_parts if document.chart_parts
          package.custom_xml_items = document.custom_xml_items if document.custom_xml_items
          package.bibliography_sources = document.bibliography_sources if document.bibliography_sources
          package.embeddings = document.embeddings if document.embeddings
        end

        # Create minimal content types for a valid DOCX
        def minimal_content_types
          ct = Uniword::ContentTypes::Types.new
          ct.defaults ||= []
          ct.defaults << Uniword::ContentTypes::Default.new(
            extension: "rels",
            content_type: "application/vnd.openxmlformats-package.relationships+xml",
          )
          ct.defaults << Uniword::ContentTypes::Default.new(
            extension: "xml",
            content_type: "application/xml",
          )

          ct.overrides ||= []
          ct.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/document.xml",
            content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
          )
          ct.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/styles.xml",
            content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml",
          )
          ct.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/fontTable.xml",
            content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml",
          )
          ct.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/settings.xml",
            content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml",
          )
          ct.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/word/webSettings.xml",
            content_type: "application/vnd.openxmlformats-officedocument.wordprocessingml.webSettings+xml",
          )
          ct.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/docProps/app.xml",
            content_type: "application/vnd.openxmlformats-officedocument.extended-properties+xml",
          )
          ct.overrides << Uniword::ContentTypes::Override.new(
            part_name: "/docProps/core.xml",
            content_type: "application/vnd.openxmlformats-package.core-properties+xml",
          )
          ct
        end

        # Create minimal package relationships for a valid DOCX
        def minimal_package_rels
          rels = Ooxml::Relationships::PackageRelationships.new
          rels.relationships ||= []
          rels.relationships << Ooxml::Relationships::Relationship.new(
            id: "rId1",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument",
            target: "word/document.xml",
          )
          rels.relationships << Ooxml::Relationships::Relationship.new(
            id: "rId2",
            type: "http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties",
            target: "docProps/core.xml",
          )
          rels.relationships << Ooxml::Relationships::Relationship.new(
            id: "rId3",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties",
            target: "docProps/app.xml",
          )
          rels
        end

        # Create minimal document relationships for a valid DOCX
        def minimal_document_rels
          rels = Ooxml::Relationships::PackageRelationships.new
          rels.relationships ||= []
          rels.relationships << Ooxml::Relationships::Relationship.new(
            id: "rId1",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles",
            target: "styles.xml",
          )
          rels.relationships << Ooxml::Relationships::Relationship.new(
            id: "rId2",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings",
            target: "settings.xml",
          )
          rels.relationships << Ooxml::Relationships::Relationship.new(
            id: "rId3",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/webSettings",
            target: "webSettings.xml",
          )
          rels.relationships << Ooxml::Relationships::Relationship.new(
            id: "rId4",
            type: "http://schemas.openxmlformats.org/officeDocument/2006/relationships/fontTable",
            target: "fontTable.xml",
          )
          rels
        end
      end
    end
  end
end
