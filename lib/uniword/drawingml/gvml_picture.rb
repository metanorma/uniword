# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # GVML picture
    #
    # Element: <pic>
    class GvmlPicture < Lutaml::Model::Serializable
      attribute :nv_pic_pr, GvmlPictureNonVisual
      attribute :blip_fill, BlipFill
      attribute :sp_pr, ShapeProperties
      attribute :style, :string

      xml do
        element 'pic'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'nvPicPr', to: :nv_pic_pr, render_nil: false
        map_element 'blipFill', to: :blip_fill, render_nil: false
        map_element 'spPr', to: :sp_pr, render_nil: false
        map_element 'style', to: :style, render_nil: false
      end
    end
  end
end
