# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # GVML graphic frame non-visual properties
    #
    # Element: <nvGraphicFramePr>
    class GvmlGraphicFrameNonVisual < Lutaml::Model::Serializable
      attribute :c_nv_pr, NonVisualDrawingProperties
      attribute :c_nv_graphic_frame_pr, NonVisualGraphicFrameProperties

      xml do
        element "nvGraphicFramePr"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element "cNvPr", to: :c_nv_pr, render_nil: false
        map_element "cNvGraphicFramePr", to: :c_nv_graphic_frame_pr, render_nil: false
      end
    end
  end
end
