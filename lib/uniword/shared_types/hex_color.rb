# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module SharedTypes
      # Hexadecimal color value (RGB)
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:hex_color>
      class HexColor < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'hex_color'
            namespace Uniword::Ooxml::Namespaces::SharedTypes

            map_attribute 'val', to: :val
          end
      end
    end
end
