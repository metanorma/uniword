# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Auto title deleted flag
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:autoTitleDeleted>
      class AutoTitleDeleted < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'autoTitleDeleted'
            namespace Uniword::Ooxml::Namespaces::Chart

            map_attribute 'val', to: :val
          end
      end
    end
end
