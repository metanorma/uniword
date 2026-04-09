# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Customxml
    # End marker for custom XML move-to range in track changes
    #
    # Generated from OOXML schema: customxml.yml
    # Element: <cxml:custom_xml_move_to_range_end>
    class CustomXmlMoveToRangeEnd < Lutaml::Model::Serializable
      attribute :id, :string

      xml do
        element 'custom_xml_move_to_range_end'
        namespace Uniword::Ooxml::Namespaces::CustomXml

        map_attribute 'id', to: :id
      end
    end
  end
end
