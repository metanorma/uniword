# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Customxml
    # Element name for smart tag type
    #
    # Generated from OOXML schema: customxml.yml
    # Element: <cxml:smart_tag_element>
    class SmartTagElement < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'smart_tag_element'
        namespace Uniword::Ooxml::Namespaces::CustomXml

        map_attribute 'val', to: :val
      end
    end
  end
end
