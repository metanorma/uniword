# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Chart legend
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:legend>
    class Legend < Lutaml::Model::Serializable
      attribute :legend_pos, LegendPosition
      attribute :legend_entry, LegendEntry, collection: true, initialize_empty: true
      attribute :layout, Layout
      attribute :overlay, :string
      attribute :sp_pr, :string
      attribute :tx_pr, :string

      xml do
        element "legend"
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element "legendPos", to: :legend_pos, render_nil: false
        map_element "legendEntry", to: :legend_entry, render_nil: false
        map_element "layout", to: :layout, render_nil: false
        map_element "overlay", to: :overlay, render_nil: false
        map_element "spPr", to: :sp_pr, render_nil: false
        map_element "txPr", to: :tx_pr, render_nil: false
      end
    end
  end
end
