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
        # Part kinds in a minimal [Content_Types].xml, emission order.
        MINIMAL_CT_DEFAULT_PARTS = %i[rels xml].freeze
        MINIMAL_CT_OVERRIDE_PARTS =
          %i[document styles font_table settings web_settings
             app_properties core_properties].freeze

        # Part kinds in a minimal _rels/.rels, in rId order.
        MINIMAL_PACKAGE_REL_PARTS =
          %i[document core_properties app_properties].freeze

        # Part kinds in a minimal word/_rels/document.xml.rels,
        # in rId order.
        MINIMAL_DOCUMENT_REL_PARTS =
          %i[styles settings web_settings font_table].freeze

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
          if document.settings_rels
            package.settings_rels = document.settings_rels
          end
          if document.footnotes_rels
            package.footnotes_rels = document.footnotes_rels
          end
          if document.endnotes_rels
            package.endnotes_rels = document.endnotes_rels
          end
          package.content_types = document.content_types if document.content_types
          package.footnotes = document.footnotes if document.footnotes
          package.endnotes = document.endnotes if document.endnotes
          if document.comments.is_a?(Uniword::CommentsPart)
            package.comments = document.comments
          end
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
          ct.defaults = MINIMAL_CT_DEFAULT_PARTS.map do |key|
            defn = Ooxml::PartRegistry.find_by_key(key)
            Uniword::ContentTypes::Default.new(
              extension: defn.extension,
              content_type: defn.content_type,
            )
          end
          ct.overrides = MINIMAL_CT_OVERRIDE_PARTS.map do |key|
            defn = Ooxml::PartRegistry.find_by_key(key)
            Uniword::ContentTypes::Override.new(
              part_name: defn.part_name,
              content_type: defn.content_type,
            )
          end
          ct
        end

        # Create minimal package relationships for a valid DOCX
        def minimal_package_rels
          build_minimal_rels(MINIMAL_PACKAGE_REL_PARTS)
        end

        # Create minimal document relationships for a valid DOCX
        def minimal_document_rels
          build_minimal_rels(MINIMAL_DOCUMENT_REL_PARTS)
        end

        private

        # Build a Relationships part with sequential rIds (rId1..rIdN)
        # for the given registry part keys, in the given order.
        def build_minimal_rels(part_keys)
          rels = Ooxml::Relationships::PackageRelationships.new
          rels.relationships = part_keys.each_with_index.map do |key, idx|
            defn = Ooxml::PartRegistry.find_by_key(key)
            Ooxml::Relationships::Relationship.new(
              id: "rId#{idx + 1}",
              type: defn.rel_type,
              target: defn.target,
            )
          end
          rels
        end
      end
    end
  end
end
