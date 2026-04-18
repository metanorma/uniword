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

      def self.included(base)
        base.extend(ClassMethods)
        base.const_set(:DOCUMENT_TO_PACKAGE_MAPPINGS,
                       DOCUMENT_TO_PACKAGE_MAPPINGS)
      end

      # Class methods for package construction
      module ClassMethods
        # Copy parts from document to package for round-trip preservation
        def copy_document_parts_to_package(document, package)
          return unless document.is_a?(Uniword::Wordprocessingml::DocumentRoot)

          DOCUMENT_TO_PACKAGE_MAPPINGS.each do |doc_attr, pkg_attr|
            value = document.send(doc_attr)
            package.send(:"#{pkg_attr}=", value) if value
          end

          if document.numbering_configuration_loaded?
            package.numbering = document.numbering_configuration
          end

          package.chart_parts = document.chart_parts if document.chart_parts
          package.custom_xml_items = document.custom_xml_items if document.custom_xml_items
          package.bibliography_sources = document.bibliography_sources if document.bibliography_sources
        end

        # Create minimal content types for a valid DOCX
        def minimal_content_types
          ct = Uniword::ContentTypes::Types.new
          ct.defaults ||= []
          ct.defaults << Uniword::ContentTypes::Default.new(
            extension: "rels",
            content_type: "application/vnd.openxmlformats-package.relationships+xml"
          )
          ct.defaults << Uniword::ContentTypes::Default.new(
            extension: "xml",
            content_type: "application/xml"
          )

          %w[png jpeg jpg gif bmp tif tiff svg].each do |ext|
            mime = case ext
                   when "jpg", "jpeg" then "image/jpeg"
                   when "png" then "image/png"
                   when "gif" then "image/gif"
                   when "bmp" then "image/bmp"
                   when "tif", "tiff" then "image/tiff"
                   when "svg" then "image/svg+xml"
                   end
            ct.defaults << Uniword::ContentTypes::Default.new(
              extension: ext, content_type: mime
            )
          end

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
        def minimal_package_rels
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
        def minimal_document_rels
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
      end
    end
  end
end
