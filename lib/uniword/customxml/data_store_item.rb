# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Customxml
    # Data store item from customXml/itemProps{N}.xml
    #
    # Element: <ds:datastoreItem ds:itemID="{GUID}">
    # Namespace: http://schemas.openxmlformats.org/officeDocument/2006/customXml
    class DataStoreItem < Lutaml::Model::Serializable
      attribute :item_id, :string
      attribute :schema_refs, SchemaRefs

      xml do
        element "datastoreItem"
        namespace Uniword::Ooxml::Namespaces::CustomXml

        map_attribute "itemID", to: :item_id
        map_element "schemaRefs", to: :schema_refs, render_nil: false
      end
    end
  end
end
