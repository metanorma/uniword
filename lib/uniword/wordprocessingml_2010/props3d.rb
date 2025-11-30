# frozen_string_literal: true

require 'lutaml/model'

module Uniword
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
        element 'props3d'
        namespace Uniword::Ooxml::Namespaces::Word2010

        map_attribute 'extrusion-height', to: :extrusion_height
        map_attribute 'contour-width', to: :contour_width
        map_attribute 'material', to: :material
      end
    end
  end
end
