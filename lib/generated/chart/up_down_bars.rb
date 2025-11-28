# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Up/down bars
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:upDownBars>
      class UpDownBars < Lutaml::Model::Serializable
          attribute :gap_width, GapWidth
          attribute :up_bars, :string
          attribute :down_bars, :string

          xml do
            root 'upDownBars'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'
            mixed_content

            map_element 'gapWidth', to: :gap_width, render_nil: false
            map_element 'upBars', to: :up_bars, render_nil: false
            map_element 'downBars', to: :down_bars, render_nil: false
          end
      end
    end
  end
end
