# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # Row-level custom XML element for table rows
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:custom_xml_row>
      class CustomXmlRow < Lutaml::Model::Serializable
          attribute :uri, :string
          attribute :element, :string
          attribute :custom_xml_pr, CustomXmlProperties
          attribute :content, :string, collection: true, default: -> { [] }

          xml do
            root 'custom_xml_row'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'
            mixed_content

            map_attribute 'uri', to: :uri
            map_attribute 'element', to: :element
            map_element 'customXmlPr', to: :custom_xml_pr, render_nil: false
            map_element '', to: :content, render_nil: false
          end
      end
    end
  end
end
