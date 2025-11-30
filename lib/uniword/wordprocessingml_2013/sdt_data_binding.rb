# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2013
    # Enhanced data binding for content controls
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:dataBinding>
    class SdtDataBinding < Lutaml::Model::Serializable
      attribute :xpath, String
      attribute :store_item_id, String

      xml do
        element 'dataBinding'
        namespace Uniword::Ooxml::Namespaces::Word2012

        map_attribute 'xpath', to: :xpath
        map_attribute 'store-item-id', to: :store_item_id
      end
    end
  end
end
