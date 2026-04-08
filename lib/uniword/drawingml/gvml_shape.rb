# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # GVML shape
    #
    # Element: <sp>
    class GvmlShape < Lutaml::Model::Serializable
      attribute :nv_sp_pr, GvmlShapeNonVisual
      attribute :sp_pr, ShapeProperties
      attribute :tx_sp, GvmlTextShape
      attribute :style, :string

      xml do
        element 'sp'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'nvSpPr', to: :nv_sp_pr, render_nil: false
        map_element 'spPr', to: :sp_pr, render_nil: false
        map_element 'txSp', to: :tx_sp, render_nil: false
        map_element 'style', to: :style, render_nil: false
      end
    end
  end
end
