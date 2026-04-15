# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # GVML text shape
    #
    # Element: <textShape>
    class GvmlTextShape < Lutaml::Model::Serializable
      attribute :tx_body, TextBody
      attribute :use_sp_rect, GvmlUseShapeRectangle
      attribute :xfrm, Transform2D

      xml do
        element "textShape"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element "txBody", to: :tx_body, render_nil: false
        map_element "useSpRect", to: :use_sp_rect, render_nil: false
        map_element "xfrm", to: :xfrm, render_nil: false
      end
    end
  end
end
