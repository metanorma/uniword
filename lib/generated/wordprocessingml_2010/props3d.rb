# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2010
      # 3D text properties
      #
      # Generated from OOXML schema: wordprocessingml_2010.yml
      # Element: <w14:props3d>
      class Props3d < Lutaml::Model::Serializable
          attribute :extrusion_height, Integer
          attribute :contour_width, Integer
          attribute :material, String

          xml do
            root 'props3d'
            namespace 'http://schemas.microsoft.com/office/word/2010/wordml', 'w14'

            map_attribute 'true', to: :extrusion_height
            map_attribute 'true', to: :contour_width
            map_attribute 'true', to: :material
          end
      end
    end
  end
end
