# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Area chart definition
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:areaChart>
    class AreaChart < Lutaml::Model::Serializable
      attribute :grouping, :string
      attribute :vary_colors, :string
      attribute :series, :string, collection: true, initialize_empty: true
      attribute :d_lbls, DataLabels
      attribute :drop_lines, DropLines
      attribute :ax_id, AxisId, collection: true, initialize_empty: true

      xml do
        element "areaChart"
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element "grouping", to: :grouping, render_nil: false
        map_element "varyColors", to: :vary_colors, render_nil: false
        map_element "ser", to: :series, render_nil: false
        map_element "dLbls", to: :d_lbls, render_nil: false
        map_element "dropLines", to: :drop_lines, render_nil: false
        map_element "axId", to: :ax_id
      end
    end
  end
end
