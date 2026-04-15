# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Customxml
    # Name value for smart tag or custom XML
    #
    # Generated from OOXML schema: customxml.yml
    # Element: <cxml:name>
    class Name < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "name"
        namespace Uniword::Ooxml::Namespaces::CustomXml

        map_attribute "val", to: :val
      end
    end
  end
end
