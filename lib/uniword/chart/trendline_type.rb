# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Trendline type
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:trendlineType>
      class TrendlineType < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'trendlineType'
            namespace Uniword::Ooxml::Namespaces::Chart

            map_attribute 'val', to: :val
          end
      end
    end
end
