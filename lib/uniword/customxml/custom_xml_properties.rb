# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Customxml
      # Properties for custom XML elements
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:custom_xml_properties>
      class CustomXmlProperties < Lutaml::Model::Serializable
          attribute :placeholder, :string
          attribute :showing_plc_hdr, :string
          attribute :attr, CustomXmlAttribute, collection: true, default: -> { [] }

          xml do
            element 'custom_xml_properties'
            namespace Uniword::Ooxml::Namespaces::CustomXml
            mixed_content

            map_attribute 'placeholder', to: :placeholder
            map_attribute 'showingPlcHdr', to: :showing_plc_hdr
            map_element 'attr', to: :attr, render_nil: false
          end
      end
    end
end
