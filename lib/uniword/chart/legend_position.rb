# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Legend position
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:legendPos>
      class LegendPosition < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'legendPos'
            namespace Uniword::Ooxml::Namespaces::Chart

            map_attribute 'val', to: :val
          end
      end
    end
end
