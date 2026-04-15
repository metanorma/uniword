# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # GVML use shape rectangle (empty type)
    #
    # Element: <useShapeRectangle>
    class GvmlUseShapeRectangle < Lutaml::Model::Serializable
      xml do
        element "useShapeRectangle"
        namespace Uniword::Ooxml::Namespaces::DrawingML
      end
    end
  end
end
