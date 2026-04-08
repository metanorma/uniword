# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Non-visual group drawing shape properties
    #
    # Element: <a:cNvGrpSpPr>
    class NonVisualGroupDrawingShapeProperties < Lutaml::Model::Serializable
      attribute :id, :string

      xml do
        element 'cNvGrpSpPr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'id', to: :id
      end
    end
  end
end
