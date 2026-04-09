# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Customxml
    # Namespace URI for smart tag
    #
    # Generated from OOXML schema: customxml.yml
    # Element: <cxml:smart_tag_uri>
    class SmartTagUri < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'smart_tag_uri'
        namespace Uniword::Ooxml::Namespaces::CustomXml

        map_attribute 'val', to: :val
      end
    end
  end
end
