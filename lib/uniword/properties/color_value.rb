# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Namespaced custom type for color value
    class ColorValueType < Lutaml::Model::Type::String
    end

    # Color value element
    #
    # Represents <w:color w:val="..." w:themeColor="..." w:themeShade="..."/>
    # where value is RGB hex (e.g., "FF0000") and themeColor references theme (e.g., "background1")
    # themeShade is a hex tint value (e.g., "BF")
    class ColorValue < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :value, ColorValueType
      attribute :theme_color, :string
      attribute :theme_shade, :string
      attribute :theme_tint, :string

      xml do
        element 'color'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :value
        map_attribute 'themeColor', to: :theme_color, render_nil: false
        map_attribute 'themeShade', to: :theme_shade, render_nil: false
        map_attribute 'themeTint', to: :theme_tint, render_nil: false
      end

      # Compare with another ColorValue or a string
      def ==(other)
        if other.is_a?(ColorValue)
          value == other.value
        elsif other.is_a?(String)
          value == other
        else
          super
        end
      end

      alias eql? ==

      # For string interpolation
      def to_s
        value.to_s
      end

      # For hash key compatibility
      def hash
        value.hash
      end
    end
  end
end
