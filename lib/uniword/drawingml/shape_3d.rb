# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # 3D shape properties
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:sp3d>
    class Shape3D < Lutaml::Model::Serializable
      attribute :contour_w, :integer
      attribute :prst_material, :string
      attribute :bevel_t, BevelTop
      attribute :contour_clr, SolidFill

      xml do
        element "sp3d"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "contourW", to: :contour_w, render_nil: false
        map_attribute "prstMaterial", to: :prst_material, render_nil: false
        map_element "bevelT", to: :bevel_t, render_nil: false
        map_element "contourClr", to: :contour_clr, render_nil: false
      end
    end
  end
end
