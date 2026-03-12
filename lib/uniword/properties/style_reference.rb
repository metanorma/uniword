# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Namespaced custom type for style reference value
    class StyleReferenceValue < Lutaml::Model::Type::String
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    # Style reference element
    #
    # Represents <w:pStyle w:val="..."/> or <w:rStyle w:val="..."/>
    # where value is the style ID being referenced
    class StyleReference < Lutaml::Model::Serializable
      attribute :value, StyleReferenceValue

      xml do
        element 'pStyle' # Default, can be overridden
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
