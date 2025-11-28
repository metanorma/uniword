# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Gap width between bars/columns
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:gapWidth>
      class GapWidth < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'gapWidth'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
