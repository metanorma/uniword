# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module SharedTypes
    # Measurement in pixels
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:pixel_measure>
    #
    # Value constrained to ST_PixelsMeasure (ECMA-376): non-negative
    # integer; see Ooxml::Types::UnsignedDecimalNumber.
    class PixelMeasure < Lutaml::Model::Serializable
      attribute :val, Uniword::Ooxml::Types::UnsignedDecimalNumber

      xml do
        element "pixel_measure"
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute "val", to: :val
      end
    end
  end
end
