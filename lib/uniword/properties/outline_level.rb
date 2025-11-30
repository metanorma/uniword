# frozen_string_literal: true

require 'lutaml/model'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Namespaced custom type for outline level value
    class OutlineLevelValue < Lutaml::Model::Type::Integer
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    # Outline level element
    #
    # Represents <w:outlineLvl w:val="..."/> where value is 0-9
    # Used for table of contents generation
    class OutlineLevel < Lutaml::Model::Serializable
      attribute :value, OutlineLevelValue
      
      xml do
        element 'outlineLvl'
        namespace Ooxml::Namespaces::WordProcessingML
        
        map_attribute 'val', to: :value
      end
    end
  end
end