# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Data labels collection
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:dLbls>
    class DataLabels < Lutaml::Model::Serializable
      attribute :d_lbl, DataLabel, collection: true, initialize_empty: true
      attribute :show_legend_key, ShowLegendKey
      attribute :show_val, ShowValue
      attribute :show_cat_name, ShowCategoryName
      attribute :show_ser_name, :string
      attribute :show_percent, :string
      attribute :show_bubble_size, :string
      attribute :separator, :string
      attribute :sp_pr, :string
      attribute :tx_pr, :string

      xml do
        element "dLbls"
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element "dLbl", to: :d_lbl, render_nil: false
        map_element "showLegendKey", to: :show_legend_key, render_nil: false
        map_element "showVal", to: :show_val, render_nil: false
        map_element "showCatName", to: :show_cat_name, render_nil: false
        map_element "showSerName", to: :show_ser_name, render_nil: false
        map_element "showPercent", to: :show_percent, render_nil: false
        map_element "showBubbleSize", to: :show_bubble_size, render_nil: false
        map_element "separator", to: :separator, render_nil: false
        map_element "spPr", to: :sp_pr, render_nil: false
        map_element "txPr", to: :tx_pr, render_nil: false
      end
    end
  end
end
