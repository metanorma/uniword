# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Chart
    # Chart container
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:chart>
    class Chart < Lutaml::Model::Serializable
      attribute :title, Title
      attribute :auto_title_deleted, AutoTitleDeleted
      attribute :plot_area, PlotArea
      attribute :legend, Legend
      attribute :plot_vis_only, PlotVisOnly
      attribute :disp_blanks_as, :string

      xml do
        element "chart"
        namespace Uniword::Ooxml::Namespaces::Chart
        mixed_content

        map_element "title", to: :title, render_nil: false
        map_element "autoTitleDeleted", to: :auto_title_deleted,
                                        render_nil: false
        map_element "plotArea", to: :plot_area
        map_element "legend", to: :legend, render_nil: false
        map_element "plotVisOnly", to: :plot_vis_only, render_nil: false
        map_element "dispBlanksAs", to: :disp_blanks_as, render_nil: false
      end
    end
  end
end
