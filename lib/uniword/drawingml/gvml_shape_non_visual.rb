# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # GVML shape non-visual properties
    #
    # Element: <nvSpPr>
    class GvmlShapeNonVisual < Lutaml::Model::Serializable
      attribute :c_nv_pr, NonVisualDrawingProperties
      attribute :c_nv_sp_pr, NonVisualShapeProperties

      xml do
        element 'nvSpPr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'cNvPr', to: :c_nv_pr, render_nil: false
        map_element 'cNvSpPr', to: :c_nv_sp_pr, render_nil: false
      end
    end
  end
end
