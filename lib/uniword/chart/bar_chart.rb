# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Bar chart definition
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:barChart>
    class BarChart < Lutaml::Model::Serializable
      attribute :bar_dir, :string
      attribute :grouping, :string
      attribute :vary_colors, :string
      attribute :series, :string, collection: true, initialize_empty: true
      attribute :d_lbls, DataLabels
      attribute :gap_width, GapWidth
      attribute :overlap, :string
      attribute :ax_id, AxisId, collection: true, initialize_empty: true

      xml do
        element 'barChart'
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element 'barDir', to: :bar_dir
        map_element 'grouping', to: :grouping, render_nil: false
        map_element 'varyColors', to: :vary_colors, render_nil: false
        map_element 'ser', to: :series, render_nil: false
        map_element 'dLbls', to: :d_lbls, render_nil: false
        map_element 'gapWidth', to: :gap_width, render_nil: false
        map_element 'overlap', to: :overlap, render_nil: false
        map_element 'axId', to: :ax_id
      end
    end
  end
end
