# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Marker style
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:markerStyle>
      class MarkerStyle < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'markerStyle'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
