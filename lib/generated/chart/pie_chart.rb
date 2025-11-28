# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Pie chart definition
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:pieChart>
      class PieChart < Lutaml::Model::Serializable
          attribute :vary_colors, :string
          attribute :series, :string, collection: true, default: -> { [] }
          attribute :d_lbls, DataLabels
          attribute :first_slice_ang, :string

          xml do
            root 'pieChart'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'
            mixed_content

            map_element 'varyColors', to: :vary_colors, render_nil: false
            map_element 'ser', to: :series, render_nil: false
            map_element 'dLbls', to: :d_lbls, render_nil: false
            map_element 'firstSliceAng', to: :first_slice_ang, render_nil: false
          end
      end
    end
  end
end
