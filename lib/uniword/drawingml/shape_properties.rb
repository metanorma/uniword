# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Shape visual properties
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:spPr>
    class ShapeProperties < Lutaml::Model::Serializable
      attribute :xfrm, Transform2D
      attribute :ln, LineProperties

      xml do
        element 'spPr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'xfrm', to: :xfrm, render_nil: false
        map_element 'ln', to: :ln, render_nil: false
      end
    end
  end
end
