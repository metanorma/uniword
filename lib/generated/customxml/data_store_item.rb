# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # Reference to a data store item containing custom XML data
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:data_store_item>
      class DataStoreItem < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :schema_ref, SchemaReference

          xml do
            root 'data_store_item'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'
            mixed_content

            map_attribute 'id', to: :id
            map_element 'schemaRef', to: :schema_ref, render_nil: false
          end
      end
    end
  end
end
