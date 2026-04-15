# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Chart reference element inside DrawingML GraphicData.
    #
    # References a chart part via relationship ID:
    #   <c:chart r:id="rIdChart1"/>
    #
    # Element: <c:chart> (inside <a:graphicData>)
    class ChartReference < Lutaml::Model::Serializable
      attribute :id, :string

      xml do
        element "chart"
        namespace Uniword::Ooxml::Namespaces::Chart

        map_attribute "id", to: :id, render_nil: false
      end
    end
  end
end
