# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml2016
      # Enhanced data binding with accessibility features
      #
      # Generated from OOXML schema: wordprocessingml_2016.yml
      # Element: <w16:dataBinding>
      class DataBinding2016 < Lutaml::Model::Serializable
          attribute :xpath, String
          attribute :store_item_id, String
          attribute :prefix_mappings, String

          xml do
            element 'dataBinding'
            namespace Uniword::Ooxml::Namespaces::Word2015

            map_attribute 'xpath', to: :xpath
            map_attribute 'store-item-id', to: :store_item_id
            map_attribute 'prefix-mappings', to: :prefix_mappings
          end
      end
    end
end
