# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Color definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:color>
      class Color < Lutaml::Model::Serializable
          attribute :rgb, String
          attribute :theme, Integer
          attribute :tint, String
          attribute :indexed, Integer

          xml do
            root 'color'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :rgb
            map_attribute 'true', to: :theme
            map_attribute 'true', to: :tint
            map_attribute 'true', to: :indexed
          end
      end
    end
  end
end
