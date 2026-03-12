# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Namespaced custom type for width scale value
    class WidthScaleValue < Lutaml::Model::Type::Integer
      xml_namespace Ooxml::Namespaces::WordProcessingML
    end

    # Width scaling element (horizontal text scaling)
    #
    # Represents <w:w w:val="..."/> where value is:
    # - Integer percentage (50-600)
    # - 100 = normal width (default)
    # - < 100 = condensed (e.g., 80 = 80% width)
    # - > 100 = expanded (e.g., 150 = 150% width)
    class WidthScale < Lutaml::Model::Serializable
      attribute :value, WidthScaleValue

      xml do
        element 'w'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
