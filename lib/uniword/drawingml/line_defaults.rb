# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Line defaults for object defaults
    #
    # Element: <a:lnDef>
    class LineDefaults < Lutaml::Model::Serializable
      attribute :sp_pr, ShapeProperties
      attribute :body_pr, BodyProperties
      attribute :lst_style, ListStyle
      attribute :style, StyleMatrix

      xml do
        element 'lnDef'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_element 'spPr', to: :sp_pr, render_nil: false
        map_element 'bodyPr', to: :body_pr, render_nil: false
        map_element 'lstStyle', to: :lst_style, render_nil: false
        map_element 'style', to: :style, render_nil: false
      end
    end
  end
end
