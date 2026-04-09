# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # GVML picture non-visual properties
    #
    # Element: <nvPicPr>
    class GvmlPictureNonVisual < Lutaml::Model::Serializable
      attribute :c_nv_pr, NonVisualDrawingProperties
      attribute :c_nv_pic_pr, NonVisualPictureProperties

      xml do
        element 'nvPicPr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'cNvPr', to: :c_nv_pr, render_nil: false
        map_element 'cNvPicPr', to: :c_nv_pic_pr, render_nil: false
      end
    end
  end
end
