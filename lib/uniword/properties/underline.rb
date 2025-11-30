# frozen_string_literal: true

require 'lutaml/model'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Namespaced custom type for underline value
    class UnderlineValue < Lutaml::Model::Type::String
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    # Text underline element
    #
    # Represents <w:u w:val="..."/> where value is:
    # - single, double, thick, dotted, dashed, wave, none, etc.
    class Underline < Lutaml::Model::Serializable
      attribute :value, UnderlineValue
      
      xml do
        element 'u'
        namespace Ooxml::Namespaces::WordProcessingML
        
        map_attribute 'val', to: :value
      end
    end
  end
end