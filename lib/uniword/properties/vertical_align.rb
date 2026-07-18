# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Namespaced custom type for vertical alignment value
    class VerticalAlignValue < Lutaml::Model::Type::String
      # Full ST_VerticalAlignRun enumeration from ECMA-376 (wml.xsd)
      VALUES = %w[baseline superscript subscript].freeze
    end

    # Text vertical alignment element
    #
    # Represents <w:vertAlign w:val="..."/> where value is from
    # ST_VerticalAlignRun (ECMA-376): baseline, superscript, subscript
    class VerticalAlign < Lutaml::Model::Serializable
      attribute :value, VerticalAlignValue,
                values: VerticalAlignValue::VALUES

      xml do
        element "vertAlign"
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :value
      end
    end
  end
end
