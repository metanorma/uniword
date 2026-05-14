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
      attribute :bookmark_starts, BookmarkStart, collection: true,
                                                 initialize_empty: true
      attribute :bookmark_ends, BookmarkEnd, collection: true,
                                             initialize_empty: true

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

        counts = element_order.each_with_object(Hash.new(0)) do |e, h|
          h[e.name] += 1
        end

        needed = false
        needed = true if paragraphs.size > counts["p"]
        needed = true if tables.size > counts["tbl"]
        needed = true if structured_document_tags.size > counts["sdt"]
        needed = true if bookmark_starts.size > counts["bookmarkStart"]
        needed = true if bookmark_ends.size > counts["bookmarkEnd"]
        needed = true if section_properties && counts["sectPr"].zero?

        return unless needed

        dup_element_order_if_frozen

        append_missing_elements("p", paragraphs.size - counts["p"])
        append_missing_elements("tbl", tables.size - counts["tbl"])
        append_missing_elements("sdt",
                                structured_document_tags.size - counts["sdt"])
        append_missing_elements("bookmarkStart",
                                bookmark_starts.size - counts["bookmarkStart"])
        append_missing_elements("bookmarkEnd",
                                bookmark_ends.size - counts["bookmarkEnd"])

        return unless section_properties && counts["sectPr"].zero?

        element_order << build_order_element("sectPr")
      end

      def dup_element_order_if_frozen
        return unless element_order.frozen?

        self.element_order = element_order.dup
      end

      def append_missing_elements(name, count)
        count.times { element_order << build_order_element(name) }
      end

      def build_order_element(name)
        Lutaml::Xml::Element.new("Element", name)
      end
    end
  end
end
