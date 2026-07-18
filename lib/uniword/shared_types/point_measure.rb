# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module SharedTypes
    # Measurement in points
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:point_measure>
    #
    # Value constrained to ST_PointMeasure (ECMA-376): non-negative
    # integer; see Ooxml::Types::UnsignedDecimalNumber.
    class PointMeasure < Lutaml::Model::Serializable
      attribute :val, Uniword::Ooxml::Types::UnsignedDecimalNumber

      xml do
        element "point_measure"
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute "val", to: :val
      end
    end
  end
end
