# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Picture
      # Tile properties for picture fill
      #
      # Generated from OOXML schema: picture.yml
      # Element: <pic:tile>
      class Tile < Lutaml::Model::Serializable
          attribute :tx, Integer
          attribute :ty, Integer
          attribute :sx, Integer
          attribute :sy, Integer
          attribute :algn, String

          xml do
            root 'tile'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/picture', 'pic'

            map_attribute 'true', to: :tx
            map_attribute 'true', to: :ty
            map_attribute 'true', to: :sx
            map_attribute 'true', to: :sy
            map_attribute 'true', to: :algn
          end
      end
    end
  end
end
