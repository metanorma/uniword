# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Chart style
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:style>
      class Style < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'style'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
