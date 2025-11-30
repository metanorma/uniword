# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Customxml
    # Smart tag element name specification
    #
    # Generated from OOXML schema: customxml.yml
    # Element: <cxml:element>
    class ElementName < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'element'
        namespace Uniword::Ooxml::Namespaces::CustomXml

        map_attribute 'val', to: :val
      end
    end
  end
end
