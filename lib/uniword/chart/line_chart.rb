# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Line chart definition
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:lineChart>
      class LineChart < Lutaml::Model::Serializable
          attribute :grouping, :string
          attribute :vary_colors, :string
          attribute :series, :string, collection: true, default: -> { [] }
          attribute :d_lbls, DataLabels
          attribute :drop_lines, DropLines
          attribute :hi_low_lines, HiLowLines
          attribute :up_down_bars, UpDownBars
          attribute :marker, :string
          attribute :smooth, Smooth
          attribute :ax_id, AxisId, collection: true, default: -> { [] }

          xml do
            element 'lineChart'
            namespace Uniword::Ooxml::Namespaces::Chart
            mixed_content

            map_element 'grouping', to: :grouping, render_nil: false
            map_element 'varyColors', to: :vary_colors, render_nil: false
            map_element 'ser', to: :series, render_nil: false
            map_element 'dLbls', to: :d_lbls, render_nil: false
            map_element 'dropLines', to: :drop_lines, render_nil: false
            map_element 'hiLowLines', to: :hi_low_lines, render_nil: false
            map_element 'upDownBars', to: :up_down_bars, render_nil: false
            map_element 'marker', to: :marker, render_nil: false
            map_element 'smooth', to: :smooth, render_nil: false
            map_element 'axId', to: :ax_id
          end
      end
    end
end
