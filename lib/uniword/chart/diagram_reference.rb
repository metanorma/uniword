# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Diagram reference element inside DrawingML GraphicData.
    #
    # References a diagram (SmartArt) part via relationship ID:
    #   <dgm:diagram r:id="rIdDiagram1"/>
    #
    # Element: <dgm:diagram> (inside <a:graphicData>)
    class DiagramReference < Lutaml::Model::Serializable
      attribute :id, :string

      xml do
        element "diagram"
        namespace Uniword::Ooxml::Namespaces::Diagram

        map_attribute "id", to: :id, render_nil: false
      end
    end
  end
end
