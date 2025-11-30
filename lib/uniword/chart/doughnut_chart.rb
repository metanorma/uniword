# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Doughnut chart definition
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:doughnutChart>
      class DoughnutChart < Lutaml::Model::Serializable
          attribute :vary_colors, :string
          attribute :series, :string, collection: true, default: -> { [] }
          attribute :d_lbls, DataLabels
          attribute :first_slice_ang, :string
          attribute :hole_size, :string

          xml do
            element 'doughnutChart'
            namespace Uniword::Ooxml::Namespaces::Chart
            mixed_content

            map_element 'varyColors', to: :vary_colors, render_nil: false
            map_element 'ser', to: :series, render_nil: false
            map_element 'dLbls', to: :d_lbls, render_nil: false
            map_element 'firstSliceAng', to: :first_slice_ang, render_nil: false
            map_element 'holeSize', to: :hole_size, render_nil: false
          end
      end
    end
end
