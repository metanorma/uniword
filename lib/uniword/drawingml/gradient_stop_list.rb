# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Gradient stop list container
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:gsLst>
    class GradientStopList < Lutaml::Model::Serializable
      attribute :gradient_stops, GradientStop, collection: true,
                                               initialize_empty: true

      xml do
        element "gsLst"
        namespace Uniword::Ooxml::Namespaces::DrawingML
        ordered

        map_element "gs", to: :gradient_stops, render_nil: false
      end
    end
  end
end
