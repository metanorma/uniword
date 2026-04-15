# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Customxml
    # Data binding configuration for connecting custom XML to document content
    #
    # Generated from OOXML schema: customxml.yml
    # Element: <cxml:data_binding>
    class DataBinding < Lutaml::Model::Serializable
      attribute :prefix_mappings, :string
      attribute :xpath, :string
      attribute :store_item_id, :string

      xml do
        element "data_binding"
        namespace Uniword::Ooxml::Namespaces::CustomXml

        map_attribute "prefixMappings", to: :prefix_mappings
        map_attribute "xpath", to: :xpath
        map_attribute "storeItemID", to: :store_item_id
      end
    end
  end
end
