# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Shading pattern enumeration
    #
    # Represents fill pattern types from OOXML specification
    class ShadingPatternValue < Lutaml::Model::Type::String
    end

    # Paragraph or run shading (background fill)
    #
    # Represents <w:shd> element with pattern, color, and fill attributes.
    #
    # @example Creating shading
    #   shading = Shading.new(
    #     pattern: 'clear',
    #     fill: 'FFFF00',
    #     color: 'auto'
    #   )
    class Shading < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :pattern, ShadingPatternValue
      attribute :color, Ooxml::Types::HexColorValue
      attribute :fill, Ooxml::Types::HexColorValue
      attribute :theme_fill, Ooxml::Types::ThemeColorValue,
                values: Ooxml::Types::ThemeColorValue::VALUES

      xml do
        element "shd"
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :pattern
        map_attribute "color", to: :color
        map_attribute "fill", to: :fill
        map_attribute "themeFill", to: :theme_fill, render_nil: false
      end
    end
  end
end
