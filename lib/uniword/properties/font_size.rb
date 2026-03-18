# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Namespaced custom type for font size value
    class FontSizeValue < Lutaml::Model::Type::Integer
    end

    # Font size element
    #
    # Represents <w:sz w:val="..."/> or <w:szCs w:val="..."/>
    # where value is font size in half-points (e.g., 32 = 16pt)
    class FontSize < Lutaml::Model::Serializable
      attribute :value, FontSizeValue

      xml do
        element 'sz'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
      end
    end
  end
end
