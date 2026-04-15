# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Axis position
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:axPos>
    class AxisPosition < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "axPos"
        namespace Uniword::Ooxml::Namespaces::Chart

        map_attribute "val", to: :val
      end
    end
  end
end
