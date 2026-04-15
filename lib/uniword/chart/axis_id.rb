# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Axis ID
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:axId>
    class AxisId < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "axId"
        namespace Uniword::Ooxml::Namespaces::Chart

        map_attribute "val", to: :val
      end
    end
  end
end
