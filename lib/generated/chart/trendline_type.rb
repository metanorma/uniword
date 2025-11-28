# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Trendline type
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:trendlineType>
      class TrendlineType < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'trendlineType'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
