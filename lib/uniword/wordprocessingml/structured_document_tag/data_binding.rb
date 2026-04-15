# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # Data binding for Structured Document Tag
      # Reference XML: <w:dataBinding w:xpath="/root/element"
      #                               w:storeItemID="{GUID}"
      #                               w:prefixMappings="xmlns:ns='http://example.com'"/>
      class DataBinding < Lutaml::Model::Serializable
        attribute :xpath, :string
        attribute :store_item_id, :string
        attribute :prefix_mappings, :string

        xml do
          element "dataBinding"
          namespace Ooxml::Namespaces::WordProcessingML
          map_attribute "xpath", to: :xpath, render_nil: false
          map_attribute "storeItemID", to: :store_item_id, render_nil: false
          map_attribute "prefixMappings", to: :prefix_mappings, render_nil: false
        end
      end
    end
  end
end
