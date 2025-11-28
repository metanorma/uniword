# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'dataBinding'
            namespace 'http://schemas.microsoft.com/office/word/2015/wordml', 'w16'

            map_attribute 'true', to: :xpath
            map_attribute 'true', to: :store_item_id
            map_attribute 'true', to: :prefix_mappings
          end
      end
    end
  end
end
