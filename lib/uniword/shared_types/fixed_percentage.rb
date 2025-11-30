# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module SharedTypes
      # Fixed percentage type (constrained range)
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:fixed_percentage>
      class FixedPercentage < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            element 'fixed_percentage'
            namespace Uniword::Ooxml::Namespaces::SharedTypes

            map_attribute 'val', to: :val
          end
      end
    end
end
