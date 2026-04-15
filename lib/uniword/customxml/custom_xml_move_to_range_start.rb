# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Customxml
    # Start marker for custom XML move-to range in track changes
    #
    # Generated from OOXML schema: customxml.yml
    # Element: <cxml:custom_xml_move_to_range_start>
    class CustomXmlMoveToRangeStart < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :author, :string
      attribute :date, :string

      xml do
        element "custom_xml_move_to_range_start"
        namespace Uniword::Ooxml::Namespaces::CustomXml

        map_attribute "id", to: :id
        map_attribute "author", to: :author
        map_attribute "date", to: :date
      end
    end
  end
end
