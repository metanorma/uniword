# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Radar chart definition
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:radarChart>
      class RadarChart < Lutaml::Model::Serializable
          attribute :radar_style, :string
          attribute :vary_colors, :string
          attribute :series, :string, collection: true, default: -> { [] }
          attribute :d_lbls, DataLabels
          attribute :ax_id, AxisId, collection: true, default: -> { [] }

          xml do
            element 'radarChart'
            namespace Uniword::Ooxml::Namespaces::Chart
            mixed_content

            map_element 'radarStyle', to: :radar_style
            map_element 'varyColors', to: :vary_colors, render_nil: false
            map_element 'ser', to: :series, render_nil: false
            map_element 'dLbls', to: :d_lbls, render_nil: false
            map_element 'axId', to: :ax_id
          end
      end
    end
end
