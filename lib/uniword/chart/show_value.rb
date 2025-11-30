# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Show value flag
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:showVal>
      class ShowValue < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'showVal'
            namespace Uniword::Ooxml::Namespaces::Chart

            map_attribute 'val', to: :val
          end
      end
    end
end
