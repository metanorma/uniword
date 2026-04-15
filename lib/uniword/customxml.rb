# frozen_string_literal: true

# Customxml namespace module
# This file explicitly autoloads all Customxml classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# Custom XML markup and smart tags
# Generated from OOXML schema

require "lutaml/model"

module Uniword
  module Customxml
    # Autoload all Customxml classes (34)
    autoload :CustomXml, "uniword/customxml/custom_xml"
    autoload :CustomXmlAttribute, "uniword/customxml/custom_xml_attribute"
    autoload :CustomXmlBlock, "uniword/customxml/custom_xml_block"
    autoload :CustomXmlCell, "uniword/customxml/custom_xml_cell"
    autoload :CustomXmlDelRangeStart, "uniword/customxml/custom_xml_del_range_start"
    autoload :CustomXmlInsRangeEnd, "uniword/customxml/custom_xml_ins_range_end"
    autoload :CustomXmlInsRangeStart, "uniword/customxml/custom_xml_ins_range_start"
    autoload :CustomXmlMoveFromRangeEnd, "uniword/customxml/custom_xml_move_from_range_end"
    autoload :CustomXmlMoveFromRangeStart, "uniword/customxml/custom_xml_move_from_range_start"
    autoload :CustomXmlMoveToRangeEnd, "uniword/customxml/custom_xml_move_to_range_end"
    autoload :CustomXmlMoveToRangeStart, "uniword/customxml/custom_xml_move_to_range_start"
    autoload :CustomXmlProperties, "uniword/customxml/custom_xml_properties"
    autoload :CustomXmlRow, "uniword/customxml/custom_xml_row"
    autoload :CustomXmlRun, "uniword/customxml/custom_xml_run"
    autoload :DataBinding, "uniword/customxml/data_binding"
    autoload :DataStoreItem, "uniword/customxml/data_store_item"
    autoload :ElementName, "uniword/customxml/element_name"
    autoload :Name, "uniword/customxml/name"
    autoload :NamespaceUri, "uniword/customxml/namespace_uri"
    autoload :Placeholder, "uniword/customxml/placeholder"
    autoload :PlaceholderText, "uniword/customxml/placeholder_text"
    autoload :PrefixMappings, "uniword/customxml/prefix_mappings"
    autoload :SchemaRef, "uniword/customxml/schema_reference"
    autoload :SchemaRefs, "uniword/customxml/schema_reference"
    autoload :SchemaReference, "uniword/customxml/schema_reference"
    autoload :ShowingPlaceholder, "uniword/customxml/showing_placeholder"
    autoload :ShowingPlaceholderHeader, "uniword/customxml/showing_placeholder_header"
    autoload :SmartTag, "uniword/customxml/smart_tag"
    autoload :SmartTagAttribute, "uniword/customxml/smart_tag_attribute"
    autoload :SmartTagElement, "uniword/customxml/smart_tag_element"
    autoload :SmartTagName, "uniword/customxml/smart_tag_name"
    autoload :SmartTagProperties, "uniword/customxml/smart_tag_properties"
    autoload :SmartTagType, "uniword/customxml/smart_tag_type"
    autoload :SmartTagUri, "uniword/customxml/smart_tag_uri"
    autoload :StoreItemId, "uniword/customxml/store_item_id"
    autoload :XPath, "uniword/customxml/x_path"
    autoload :XPathExpression, "uniword/customxml/x_path_expression"
  end
end
