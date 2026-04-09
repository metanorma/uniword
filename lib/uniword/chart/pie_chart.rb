# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Pie chart definition
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:pieChart>
    class PieChart < Lutaml::Model::Serializable
      attribute :vary_colors, :string
      attribute :series, :string, collection: true, initialize_empty: true
      attribute :d_lbls, DataLabels
      attribute :first_slice_ang, :string

      xml do
        element 'pieChart'
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element 'varyColors', to: :vary_colors, render_nil: false
        map_element 'ser', to: :series, render_nil: false
        map_element 'dLbls', to: :d_lbls, render_nil: false
        map_element 'firstSliceAng', to: :first_slice_ang, render_nil: false
      end
    end
  end
end
