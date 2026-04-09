# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # GVML connector
    #
    # Element: <cxnSp>
    class GvmlConnector < Lutaml::Model::Serializable
      attribute :nv_cxn_sp_pr, GvmlConnectorNonVisual
      attribute :sp_pr, ShapeProperties
      attribute :style, :string

      xml do
        element 'cxnSp'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'nvCxnSpPr', to: :nv_cxn_sp_pr, render_nil: false
        map_element 'spPr', to: :sp_pr, render_nil: false
        map_element 'style', to: :style, render_nil: false
      end
    end
  end
end
