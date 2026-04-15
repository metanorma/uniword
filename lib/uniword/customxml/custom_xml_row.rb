# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Customxml
    # Row-level custom XML element for table rows
    #
    # Generated from OOXML schema: customxml.yml
    # Element: <cxml:custom_xml_row>
    class CustomXmlRow < Lutaml::Model::Serializable
      attribute :uri, :string
      attribute :element, :string
      attribute :custom_xml_pr, CustomXmlProperties
      attribute :content, :string, collection: true, initialize_empty: true

      xml do
        element "custom_xml_row"
        namespace Uniword::Ooxml::Namespaces::CustomXml
        mixed_content

        map_attribute "uri", to: :uri
        map_attribute "element", to: :element
        map_element "customXmlPr", to: :custom_xml_pr, render_nil: false
        map_element "", to: :content, render_nil: false
      end
    end
  end
end
