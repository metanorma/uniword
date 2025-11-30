# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Series order
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:order>
      class Order < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            element 'order'
            namespace Uniword::Ooxml::Namespaces::Chart

            map_attribute 'val', to: :val
          end
      end
    end
end
