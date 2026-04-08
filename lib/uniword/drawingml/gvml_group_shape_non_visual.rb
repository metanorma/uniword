# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # GVML group shape non-visual properties
    #
    # Element: <nvGrpSpPr>
    class GvmlGroupShapeNonVisual < Lutaml::Model::Serializable
      attribute :c_nv_pr, NonVisualDrawingProperties
      attribute :c_nv_grp_sp_pr, NonVisualGroupDrawingShapeProperties

      xml do
        element 'nvGrpSpPr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'cNvPr', to: :c_nv_pr, render_nil: false
        map_element 'cNvGrpSpPr', to: :c_nv_grp_sp_pr, render_nil: false
      end
    end
  end
end
