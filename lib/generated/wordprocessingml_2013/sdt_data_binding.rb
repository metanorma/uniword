# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2013
      # Enhanced data binding for content controls
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:dataBinding>
      class SdtDataBinding < Lutaml::Model::Serializable
          attribute :xpath, String
          attribute :store_item_id, String

          xml do
            root 'dataBinding'
            namespace 'http://schemas.microsoft.com/office/word/2012/wordml', 'w15'

            map_attribute 'true', to: :xpath
            map_attribute 'true', to: :store_item_id
          end
      end
    end
  end
end
