# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Trendline
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:trendline>
    class Trendline < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :sp_pr, :string
      attribute :trendline_type, TrendlineType
      attribute :order, Order
      attribute :period, :string
      attribute :forward, :string
      attribute :backward, :string

      xml do
        element "trendline"
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element "name", to: :name, render_nil: false
        map_element "spPr", to: :sp_pr, render_nil: false
        map_element "trendlineType", to: :trendline_type
        map_element "order", to: :order, render_nil: false
        map_element "period", to: :period, render_nil: false
        map_element "forward", to: :forward, render_nil: false
        map_element "backward", to: :backward, render_nil: false
      end
    end
  end
end
