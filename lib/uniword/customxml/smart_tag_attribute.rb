# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Customxml
    # Attribute for smart tag elements
    #
    # Generated from OOXML schema: customxml.yml
    # Element: <cxml:smart_tag_attribute>
    class SmartTagAttribute < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :val, :string

      xml do
        element "smart_tag_attribute"
        namespace Uniword::Ooxml::Namespaces::CustomXml

        map_attribute "name", to: :name
        map_attribute "val", to: :val
      end
    end
  end
end
