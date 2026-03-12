# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Namespaced custom type for emphasis mark value
    class EmphasisMarkValue < Lutaml::Model::Type::String
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    # Emphasis mark element (accent marks above/below text)
    #
    # Represents <w:em w:val="..."/> where value is:
    # - "none" = no emphasis mark
    # - "dot" = dot above text (most common)
    # - "comma" = comma above text
    # - "circle" = circle above text
    # - "underDot" = dot below text
    class EmphasisMark < Lutaml::Model::Serializable
      attribute :value, EmphasisMarkValue

      xml do
        element 'em'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
