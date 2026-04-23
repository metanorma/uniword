# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # GVML graphical object frame
    #
    # Element: <graphicFrame>
    class GvmlGraphicalObjectFrame < Lutaml::Model::Serializable
      attribute :nv_graphic_frame_pr, GvmlGraphicFrameNonVisual
      attribute :graphic, Graphic
      attribute :xfrm, Transform2D

      xml do
        element "graphicFrame"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element "nvGraphicFramePr", to: :nv_graphic_frame_pr,
                                        render_nil: false
        map_element "graphic", to: :graphic, render_nil: false
        map_element "xfrm", to: :xfrm, render_nil: false
      end
    end
  end
end
