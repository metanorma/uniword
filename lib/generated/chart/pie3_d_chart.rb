# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # 3D pie chart definition
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:pie3DChart>
      class Pie3DChart < Lutaml::Model::Serializable
          attribute :vary_colors, :string
          attribute :series, :string, collection: true, default: -> { [] }
          attribute :d_lbls, DataLabels

          xml do
            root 'pie3DChart'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'
            mixed_content

            map_element 'varyColors', to: :vary_colors, render_nil: false
            map_element 'ser', to: :series, render_nil: false
            map_element 'dLbls', to: :d_lbls, render_nil: false
          end
      end
    end
  end
end
