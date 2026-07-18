# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module SharedTypes
    # Measurement in twips (1/20th of a point)
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:twips_measure>
    #
    # Value constrained to ST_TwipsMeasure (ECMA-376): non-negative
    # integer; see Ooxml::Types::UnsignedDecimalNumber.
    class TwipsMeasure < Lutaml::Model::Serializable
      attribute :val, Uniword::Ooxml::Types::UnsignedDecimalNumber

      xml do
        element "twips_measure"
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute "val", to: :val
      end
    end
  end
end
