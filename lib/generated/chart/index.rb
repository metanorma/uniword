# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Series index
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:idx>
      class Index < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'idx'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
