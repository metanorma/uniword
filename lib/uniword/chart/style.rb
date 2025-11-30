# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Chart style
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:style>
      class Style < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            element 'style'
            namespace Uniword::Ooxml::Namespaces::Chart

            map_attribute 'val', to: :val
          end
      end
    end
end
