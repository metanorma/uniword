# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Auto title deleted flag
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:autoTitleDeleted>
      class AutoTitleDeleted < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'autoTitleDeleted'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
