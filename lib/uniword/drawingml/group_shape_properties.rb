# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Group shape visual properties
    #
    # Element: <a:grpSpPr>
    class GroupShapeProperties < Lutaml::Model::Serializable
      attribute :xfrm, Transform2D

      xml do
        element 'grpSpPr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'xfrm', to: :xfrm, render_nil: false
      end
    end
  end
end
