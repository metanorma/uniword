# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Namespaced custom type for underline value
    class UnderlineValue < Lutaml::Model::Type::String
    end

    # Text underline element
    #
    # Represents <w:u w:val="..."/> where value is:
    # - single, double, thick, dotted, dashed, wave, none, etc.
    class Underline < Lutaml::Model::Serializable
      attribute :value, UnderlineValue
      attribute :color, :string
      attribute :theme_color, :string
      attribute :theme_shade, :string

      xml do
        element 'u'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
        map_attribute 'color', to: :color
        map_attribute 'themeColor', to: :theme_color
        map_attribute 'themeShade', to: :theme_shade
      end
    end
  end
end
