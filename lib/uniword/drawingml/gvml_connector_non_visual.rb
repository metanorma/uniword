# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # GVML connector non-visual properties
    #
    # Element: <nvCxnSpPr>
    class GvmlConnectorNonVisual < Lutaml::Model::Serializable
      attribute :c_nv_pr, NonVisualDrawingProperties
      attribute :c_nv_cxn_sp_pr, NonVisualConnectorProperties

      xml do
        element 'nvCxnSpPr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'cNvPr', to: :c_nv_pr, render_nil: false
        map_element 'cNvCxnSpPr', to: :c_nv_cxn_sp_pr, render_nil: false
      end
    end
  end
end
