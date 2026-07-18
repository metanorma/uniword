# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Namespaced custom type for alignment value
    class AlignmentValue < Lutaml::Model::Type::String
      # Full ST_Jc enumeration from ECMA-376 (wml.xsd)
      VALUES = %w[
        start center end both mediumKashida distribute numTab
        highKashida lowKashida thaiDistribute left right
      ].freeze
    end

    # Paragraph alignment element
    #
    # Represents <w:jc w:val="..."/> where value is from ST_Jc
    # (ECMA-376), e.g. left, center, right, both (justified), distribute
    class Alignment < Lutaml::Model::Serializable
      attribute :value, AlignmentValue, values: AlignmentValue::VALUES

      xml do
        element "jc"
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :value
      end
    end
  end
end
