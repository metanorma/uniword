# frozen_string_literal: true

require 'lutaml/model'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Namespaced custom type for color value
    class ColorValueType < Lutaml::Model::Type::String
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    # Color value element
    #
    # Represents <w:color w:val="..."/> where value is RGB hex (e.g., "FF0000")
    class ColorValue < Lutaml::Model::Serializable
      attribute :value, ColorValueType

      xml do
        element 'color'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
