# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Document body - main content container
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:body>
    class Body < Lutaml::Model::Serializable
      attribute :paragraphs, Paragraph, collection: true, initialize_empty: true
      attribute :tables, Table, collection: true, initialize_empty: true
      attribute :section_properties, SectionProperties
      attribute :structured_document_tags, StructuredDocumentTag, collection: true,
                                                                  initialize_empty: true
      attribute :bookmark_starts, BookmarkStart, collection: true, initialize_empty: true
      attribute :bookmark_ends, BookmarkEnd, collection: true, initialize_empty: true

      xml do
        element "body"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "p", to: :paragraphs, render_nil: false
        map_element "tbl", to: :tables, render_nil: false
        map_element "sectPr", to: :section_properties, render_nil: false
        map_element "sdt", to: :structured_document_tags, render_nil: false
        map_element "bookmarkStart", to: :bookmark_starts, render_nil: false
        map_element "bookmarkEnd", to: :bookmark_ends, render_nil: false
      end

      # Get all elements in body
      #
      # @return [Array<Paragraph, Table, SectionProperties, StructuredDocumentTag>] All block-level content
      def elements
        result = []
        result.concat(paragraphs || [])
        result.concat(structured_document_tags || [])
        result.concat(tables || [])
        result << section_properties if section_properties
        result
      end

      # Override to_xml to sync element_order with actual paragraphs/tables/SDTs.
      # When Body is deserialized from XML, lutaml-model stores original
      # elements in element_order. Programmatically added paragraphs/tables/SDTs
      # are in the arrays but not in element_order, so they'd be dropped.
      # This ensures all current paragraphs, tables, and SDTs are represented.
      #
      # NOTE: lutaml-model's compiled serializer may bypass this override
      # when Body is serialized as a child of DocumentRoot. The
      # sync_element_order method is also called from DocumentRoot#to_xml.
      def to_xml(options = {})
        sync_element_order
        super
      end

      # Sync element_order with actual paragraphs/tables/SDTs.
      # Called before serialization to ensure programmatically added elements
      # are included. Also called from DocumentRoot#to_xml since
      # lutaml-model may bypass Body#to_xml when Body is a child element.
      def sync_element_order_for_serialization
        sync_element_order
      end

      private

      def sync_element_order
        return if element_order.nil? || element_order.empty?

        # Count how many p/tbl/sdt entries exist in element_order
        ordered_p_count = element_order.count { |e| e.name == "p" }
        ordered_tbl_count = element_order.count { |e| e.name == "tbl" }
        ordered_sdt_count = element_order.count { |e| e.name == "sdt" }
        ordered_bookmark_start_count = element_order.count { |e| e.name == "bookmarkStart" }
        ordered_bookmark_end_count = element_order.count { |e| e.name == "bookmarkEnd" }

        # Add missing paragraphs
        (paragraphs.size - ordered_p_count).times do
          element_order << Lutaml::Xml::Element.new("Element", "p")
        end

        # Add missing tables
        (tables.size - ordered_tbl_count).times do
          element_order << Lutaml::Xml::Element.new("Element", "tbl")
        end

        # Add missing structured document tags
        (structured_document_tags.size - ordered_sdt_count).times do
          element_order << Lutaml::Xml::Element.new("Element", "sdt")
        end

        # Add missing bookmark starts
        (bookmark_starts.size - ordered_bookmark_start_count).times do
          element_order << Lutaml::Xml::Element.new("Element", "bookmarkStart")
        end

        # Add missing bookmark ends
        (bookmark_ends.size - ordered_bookmark_end_count).times do
          element_order << Lutaml::Xml::Element.new("Element", "bookmarkEnd")
        end

        # Ensure section_properties is in element_order if present
        return unless section_properties && element_order.none? { |e| e.name == "sectPr" }

        element_order << Lutaml::Xml::Element.new("Element", "sectPr")
      end
    end
  end
end
