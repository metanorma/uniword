# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Pie slice explosion
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:explosion>
      class Explosion < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'explosion'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
