# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Column properties
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:col>
      class Col < Lutaml::Model::Serializable
          attribute :min, Integer
          attribute :max, Integer
          attribute :width, String
          attribute :style, Integer
          attribute :hidden, String
          attribute :custom_width, String

          xml do
            element 'col'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML

            map_attribute 'min', to: :min
            map_attribute 'max', to: :max
            map_attribute 'width', to: :width
            map_attribute 'style', to: :style
            map_attribute 'hidden', to: :hidden
            map_attribute 'custom-width', to: :custom_width
          end
      end
    end
end
