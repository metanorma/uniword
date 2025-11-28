# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # Run-level custom XML element for inline structured data
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:custom_xml_run>
      class CustomXmlRun < Lutaml::Model::Serializable
          attribute :uri, :string
          attribute :element, :string
          attribute :custom_xml_pr, CustomXmlProperties
          attribute :content, :string, collection: true, default: -> { [] }

          xml do
            root 'custom_xml_run'
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
