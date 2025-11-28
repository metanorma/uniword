# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Legend position
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:legendPos>
      class LegendPosition < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'legendPos'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
