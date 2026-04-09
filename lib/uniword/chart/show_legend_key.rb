# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Show legend key flag
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:showLegendKey>
    class ShowLegendKey < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'showLegendKey'
        namespace Uniword::Ooxml::Namespaces::Chart

        map_attribute 'val', to: :val
      end
    end
  end
end
