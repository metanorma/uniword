# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # Identifier for a data store item
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:store_item_id>
      class StoreItemId < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'store_item_id'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
