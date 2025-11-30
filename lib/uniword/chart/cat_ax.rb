# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Category axis
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:catAx>
      class CatAx < Lutaml::Model::Serializable
          attribute :ax_id, AxisId
          attribute :scaling, Scaling
          attribute :delete, :string
          attribute :ax_pos, AxisPosition
          attribute :major_gridlines, MajorGridlines
          attribute :minor_gridlines, MinorGridlines
          attribute :title, Title
          attribute :num_fmt, NumberingFormat
          attribute :tick_lbl_pos, TickLabelPosition
          attribute :sp_pr, :string
          attribute :tx_pr, :string
          attribute :cross_ax, :string

          xml do
            element 'catAx'
            namespace Uniword::Ooxml::Namespaces::Chart
            mixed_content

            map_element 'axId', to: :ax_id
            map_element 'scaling', to: :scaling
            map_element 'delete', to: :delete, render_nil: false
            map_element 'axPos', to: :ax_pos
            map_element 'majorGridlines', to: :major_gridlines, render_nil: false
            map_element 'minorGridlines', to: :minor_gridlines, render_nil: false
            map_element 'title', to: :title, render_nil: false
            map_element 'numFmt', to: :num_fmt, render_nil: false
            map_element 'tickLblPos', to: :tick_lbl_pos, render_nil: false
            map_element 'spPr', to: :sp_pr, render_nil: false
            map_element 'txPr', to: :tx_pr, render_nil: false
            map_element 'crossAx', to: :cross_ax
          end
      end
    end
end
