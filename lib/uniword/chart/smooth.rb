# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Smooth lines flag
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:smooth>
      class Smooth < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'smooth'
            namespace Uniword::Ooxml::Namespaces::Chart

            map_attribute 'val', to: :val
          end
      end
    end
end
