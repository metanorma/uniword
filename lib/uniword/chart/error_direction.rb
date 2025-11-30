# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Error direction
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:errDir>
      class ErrorDirection < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'errDir'
            namespace Uniword::Ooxml::Namespaces::Chart

            map_attribute 'val', to: :val
          end
      end
    end
end
