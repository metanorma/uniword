# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # 3D pie chart definition
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:pie3DChart>
    class Pie3DChart < Lutaml::Model::Serializable
      attribute :vary_colors, :string
      attribute :series, :string, collection: true, initialize_empty: true
      attribute :d_lbls, DataLabels

      xml do
        element "pie3DChart"
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element "varyColors", to: :vary_colors, render_nil: false
        map_element "ser", to: :series, render_nil: false
        map_element "dLbls", to: :d_lbls, render_nil: false
      end
    end
  end
end
