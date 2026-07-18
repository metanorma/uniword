# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module SharedTypes
    # Hexadecimal color value (RGB)
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:hex_color>
    #
    # Value constrained to ST_HexColor (ECMA-376): "auto" or six
    # hexadecimal digits; see Ooxml::Types::HexColorValue.
    class HexColor < Lutaml::Model::Serializable
      attribute :val, Uniword::Ooxml::Types::HexColorValue

      xml do
        element "hex_color"
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute "val", to: :val
      end
    end
  end
end
