# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # 3D line chart definition
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:line3DChart>
      class Line3DChart < Lutaml::Model::Serializable
          attribute :grouping, :string
          attribute :vary_colors, :string
          attribute :series, :string, collection: true, default: -> { [] }
          attribute :d_lbls, DataLabels
          attribute :drop_lines, DropLines
          attribute :gap_depth, :string
          attribute :ax_id, AxisId, collection: true, default: -> { [] }

          xml do
            root 'line3DChart'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'
            mixed_content

            map_element 'grouping', to: :grouping, render_nil: false
            map_element 'varyColors', to: :vary_colors, render_nil: false
            map_element 'ser', to: :series, render_nil: false
            map_element 'dLbls', to: :d_lbls, render_nil: false
            map_element 'dropLines', to: :drop_lines, render_nil: false
            map_element 'gapDepth', to: :gap_depth, render_nil: false
            map_element 'axId', to: :ax_id
          end
      end
    end
  end
end
