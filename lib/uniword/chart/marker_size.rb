# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Marker size
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:markerSize>
    class MarkerSize < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "markerSize"
        namespace Uniword::Ooxml::Namespaces::Chart

        map_attribute "val", to: :val
      end
    end
  end
end
