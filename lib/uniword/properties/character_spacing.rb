# frozen_string_literal: true

require 'lutaml/model'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Namespaced custom type for character spacing value
    class CharacterSpacingValue < Lutaml::Model::Type::Integer
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    # Character spacing element (expanded/condensed text)
    #
    # Represents <w:spacing w:val="..."/> in run properties where value is:
    # - Integer in twips (1/1440 inch)
    # - Positive values expand spacing between characters
    # - Negative values condense spacing
    # - Zero is normal spacing
    class CharacterSpacing < Lutaml::Model::Serializable
      attribute :value, CharacterSpacingValue

      xml do
        element 'spacing'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
