# frozen_string_literal: true

require 'lutaml/model'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Namespaced custom type for numbering ID value
    class NumberingIdValue < Lutaml::Model::Type::Integer
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    # Numbering ID element
    #
    # Represents <w:numId w:val="..."/> where value references
    # a numbering definition ID for lists (bullets, numbers)
    class NumberingId < Lutaml::Model::Serializable
      attribute :value, NumberingIdValue

      xml do
        element 'numId'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
