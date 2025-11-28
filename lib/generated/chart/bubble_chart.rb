# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Bubble chart definition
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:bubbleChart>
      class BubbleChart < Lutaml::Model::Serializable
          attribute :vary_colors, :string
          attribute :series, :string, collection: true, default: -> { [] }
          attribute :d_lbls, DataLabels
          attribute :bubble3d, :string
          attribute :bubble_scale, :string
          attribute :show_neg_bubbles, :string
          attribute :size_represents, :string
          attribute :ax_id, AxisId, collection: true, default: -> { [] }

          xml do
            root 'bubbleChart'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'
            mixed_content

            map_element 'varyColors', to: :vary_colors, render_nil: false
            map_element 'ser', to: :series, render_nil: false
            map_element 'dLbls', to: :d_lbls, render_nil: false
            map_element 'bubble3D', to: :bubble3d, render_nil: false
            map_element 'bubbleScale', to: :bubble_scale, render_nil: false
            map_element 'showNegBubbles', to: :show_neg_bubbles, render_nil: false
            map_element 'sizeRepresents', to: :size_represents, render_nil: false
            map_element 'axId', to: :ax_id
          end
      end
    end
  end
end
