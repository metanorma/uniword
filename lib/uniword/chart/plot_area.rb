# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Plot area container
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:plotArea>
    class PlotArea < Lutaml::Model::Serializable
      attribute :layout, Layout
      attribute :chart_types, :string, collection: true, initialize_empty: true
      attribute :cat_ax, CatAx, collection: true, initialize_empty: true
      attribute :val_ax, ValAx, collection: true, initialize_empty: true
      attribute :date_ax, DateAx, collection: true, initialize_empty: true
      attribute :ser_ax, SerAx, collection: true, initialize_empty: true
      attribute :sp_pr, :string

      xml do
        element 'plotArea'
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element 'layout', to: :layout, render_nil: false
        map_element '*Chart', to: :chart_types, render_nil: false
        map_element 'catAx', to: :cat_ax, render_nil: false
        map_element 'valAx', to: :val_ax, render_nil: false
        map_element 'dateAx', to: :date_ax, render_nil: false
        map_element 'serAx', to: :ser_ax, render_nil: false
        map_element 'spPr', to: :sp_pr, render_nil: false
      end
    end
  end
end
