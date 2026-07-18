# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Namespaced custom type for highlight value
    class HighlightValue < Lutaml::Model::Type::String
      # Full ST_HighlightColor enumeration from ECMA-376 (wml.xsd)
      VALUES = %w[
        black blue cyan green magenta red yellow white darkBlue
        darkCyan darkGreen darkMagenta darkRed darkYellow darkGray
        lightGray none
      ].freeze
    end

    # Text highlight element
    #
    # Represents <w:highlight w:val="..."/> where value is from
    # ST_HighlightColor (ECMA-376)
    class Highlight < Lutaml::Model::Serializable
      attribute :value, HighlightValue, values: HighlightValue::VALUES

      xml do
        element "highlight"
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :value
      end
    end
  end
end
