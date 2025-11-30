# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module SharedTypes
      # Boolean value type
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:boolean_value>
      class BooleanValue < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            element 'boolean_value'
            namespace Uniword::Ooxml::Namespaces::SharedTypes

            map_attribute 'val', to: :val
          end
      end
    end
end
