# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Legend entry
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:legendEntry>
      class LegendEntry < Lutaml::Model::Serializable
          attribute :idx, Index
          attribute :delete, :string
          attribute :tx_pr, :string

          xml do
            root 'legendEntry'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'
            mixed_content

            map_element 'idx', to: :idx
            map_element 'delete', to: :delete, render_nil: false
            map_element 'txPr', to: :tx_pr, render_nil: false
          end
      end
    end
  end
end
