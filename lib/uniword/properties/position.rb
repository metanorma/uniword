# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Namespaced custom type for position value
    class PositionValue < Lutaml::Model::Type::Integer
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    # Text position element (raised/lowered text)
    #
    # Represents <w:position w:val="..."/> where value is:
    # - Integer in half-points
    # - Positive values raise text (superscript-like)
    # - Negative values lower text (subscript-like)
    class Position < Lutaml::Model::Serializable
      attribute :value, PositionValue

      xml do
        element 'position'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
