# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Customxml
    # Custom attribute definition for custom XML elements
    #
    # Generated from OOXML schema: customxml.yml
    # Element: <cxml:custom_xml_attribute>
    class CustomXmlAttribute < Lutaml::Model::Serializable
      attribute :uri, :string
      attribute :name, :string
      attribute :val, :string

      xml do
        element 'custom_xml_attribute'
        namespace Uniword::Ooxml::Namespaces::CustomXml

        map_attribute 'uri', to: :uri
        map_attribute 'name', to: :name
        map_attribute 'val', to: :val
      end
    end
  end
end
