# frozen_string_literal: true

module Uniword
  module Docx
    # One customXml data item (customXml/itemN.xml) with its optional
    # properties part and relationships part.
    #
    # Replaces the former +{ index:, xml_content:, props_xml:,
    # rels_xml: }+ hash entries in +custom_xml_items+.
    class CustomXmlItem
      # @return [Integer] item number (customXml/item%<index>d.xml)
      attr_accessor :index

      # @return [String] raw XML of the item part
      attr_accessor :xml_content

      # @return [String, nil] raw XML of the itemProps part
      attr_accessor :props_xml

      # @return [String, nil] raw XML of the item relationships part
      attr_accessor :rels_xml

      # @param index [Integer] item number
      # @param xml_content [String] raw item XML
      # @param props_xml [String, nil] raw itemProps XML
      # @param rels_xml [String, nil] raw item relationships XML
      def initialize(index:, xml_content:, props_xml: nil, rels_xml: nil)
        @index = index
        @xml_content = xml_content
        @props_xml = props_xml
        @rels_xml = rels_xml
      end

      # Normalize a legacy hash entry (or an existing CustomXmlItem)
      # into a CustomXmlItem.
      #
      # @param value [CustomXmlItem, Hash]
      # @return [CustomXmlItem]
      def self.wrap(value)
        return value if value.is_a?(CustomXmlItem)

        new(
          index: value[:index],
          xml_content: value[:xml_content],
          props_xml: value[:props_xml],
          rels_xml: value[:rels_xml],
        )
      end

      # Package path of the item part.
      #
      # @return [String] e.g. "customXml/item1.xml"
      def path
        Ooxml::PartRegistry.find_by_key(:custom_xml_item)
          .path_for(index: index)
      end

      # Package path of the properties part.
      #
      # @return [String, nil] e.g. "customXml/itemProps1.xml"
      def props_path
        return nil unless props_xml

        Ooxml::PartRegistry.find_by_key(:custom_xml_item_props)
          .path_for(index: index)
      end

      # Package paths this item emits (item part plus its properties
      # part when present).
      #
      # @return [Array<String>] emitted package paths
      def package_paths
        [path, props_path].compact
      end

      # Hash-style read compatibility.
      #
      # @param key [Symbol, String] one of :index, :xml_content,
      #   :props_xml, :rels_xml
      # @return [Object, nil]
      def [](key)
        case key.to_sym
        when :index then index
        when :xml_content then xml_content
        when :props_xml then props_xml
        when :rels_xml then rels_xml
        end
      end
    end
  end
end
