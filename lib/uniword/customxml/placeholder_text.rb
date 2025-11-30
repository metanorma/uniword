# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Customxml
      # Placeholder text content
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:placeholder>
      class PlaceholderText < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'placeholder'
            namespace Uniword::Ooxml::Namespaces::CustomXml

            map_attribute 'val', to: :val
          end
      end
    end
end
