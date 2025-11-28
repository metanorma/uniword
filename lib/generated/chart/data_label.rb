# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Individual data label
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:dLbl>
      class DataLabel < Lutaml::Model::Serializable
          attribute :idx, Index
          attribute :delete, :string
          attribute :layout, Layout
          attribute :tx, :string
          attribute :num_fmt, NumberingFormat
          attribute :sp_pr, :string
          attribute :tx_pr, :string

          xml do
            root 'dLbl'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'
            mixed_content

            map_element 'idx', to: :idx
            map_element 'delete', to: :delete, render_nil: false
            map_element 'layout', to: :layout, render_nil: false
            map_element 'tx', to: :tx, render_nil: false
            map_element 'numFmt', to: :num_fmt, render_nil: false
            map_element 'spPr', to: :sp_pr, render_nil: false
            map_element 'txPr', to: :tx_pr, render_nil: false
          end
      end
    end
  end
end
