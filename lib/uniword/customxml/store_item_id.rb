# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Customxml
      # Identifier for a data store item
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:store_item_id>
      class StoreItemId < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'store_item_id'
            namespace Uniword::Ooxml::Namespaces::CustomXml

            map_attribute 'val', to: :val
          end
      end
    end
end
