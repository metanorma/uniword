# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Chart
      # Error bar type
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:errBarType>
      class ErrorBarType < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'errBarType'
            namespace Uniword::Ooxml::Namespaces::Chart

            map_attribute 'val', to: :val
          end
      end
    end
end
