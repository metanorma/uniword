# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Stock chart definition
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:stockChart>
    class StockChart < Lutaml::Model::Serializable
      attribute :series, :string, collection: true, initialize_empty: true
      attribute :d_lbls, DataLabels
      attribute :drop_lines, DropLines
      attribute :hi_low_lines, HiLowLines
      attribute :up_down_bars, UpDownBars
      attribute :ax_id, AxisId, collection: true, initialize_empty: true

      xml do
        element "stockChart"
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element "ser", to: :series, render_nil: false
        map_element "dLbls", to: :d_lbls, render_nil: false
        map_element "dropLines", to: :drop_lines, render_nil: false
        map_element "hiLowLines", to: :hi_low_lines, render_nil: false
        map_element "upDownBars", to: :up_down_bars, render_nil: false
        map_element "axId", to: :ax_id
      end
    end
  end
end
