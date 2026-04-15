# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Pie slice explosion
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:explosion>
    class Explosion < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "explosion"
        namespace Uniword::Ooxml::Namespaces::Chart

        map_attribute "val", to: :val
      end
    end
  end
end
