# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Tick label position
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:tickLblPos>
      class TickLabelPosition < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'tickLblPos'
            namespace Uniword::Ooxml::Namespaces::Chart

            map_attribute 'val', to: :val
          end
      end
    end
end
