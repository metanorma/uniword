# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Text defaults for object defaults
    #
    # Element: <a:txDef>
    class TextDefaults < Lutaml::Model::Serializable
      attribute :sp_pr, ShapeProperties
      attribute :body_pr, BodyProperties
      attribute :lst_style, ListStyle
      attribute :style, StyleMatrix

      xml do
        element 'txDef'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'spPr', to: :sp_pr, render_nil: false
        map_element 'bodyPr', to: :body_pr, render_nil: false
        map_element 'lstStyle', to: :lst_style, render_nil: false
        map_element 'style', to: :style, render_nil: false
      end
    end
  end
end
