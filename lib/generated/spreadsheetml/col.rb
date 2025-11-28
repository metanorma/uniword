# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'col'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :min
            map_attribute 'true', to: :max
            map_attribute 'true', to: :width
            map_attribute 'true', to: :style
            map_attribute 'true', to: :hidden
            map_attribute 'true', to: :custom_width
          end
      end
    end
  end
end
