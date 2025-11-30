# frozen_string_literal: true

require 'lutaml/model'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Namespaced custom type for numbering level value
    class NumberingLevelValue < Lutaml::Model::Type::Integer
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    # Numbering level element
    #
    # Represents <w:ilvl w:val="..."/> where value is 0-8
    # (9 levels of list nesting/indentation)
    class NumberingLevel < Lutaml::Model::Serializable
      attribute :value, NumberingLevelValue

      xml do
        element 'ilvl'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
