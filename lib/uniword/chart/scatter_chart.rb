# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Scatter chart definition
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:scatterChart>
    class ScatterChart < Lutaml::Model::Serializable
      attribute :scatter_style, :string
      attribute :vary_colors, :string
      attribute :series, :string, collection: true, default: -> { [] }
      attribute :d_lbls, DataLabels
      attribute :ax_id, AxisId, collection: true, default: -> { [] }

      xml do
        element 'scatterChart'
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element 'scatterStyle', to: :scatter_style
        map_element 'varyColors', to: :vary_colors, render_nil: false
        map_element 'ser', to: :series, render_nil: false
        map_element 'dLbls', to: :d_lbls, render_nil: false
        map_element 'axId', to: :ax_id
      end
    end
  end
end
