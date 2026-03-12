# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Shading pattern enumeration
    #
    # Represents fill pattern types from OOXML specification
    class ShadingPatternValue < Lutaml::Model::Type::String
      xml_namespace Ooxml::Namespaces::WordProcessingML
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
      attribute :color, :string      # Foreground color (RGB hex or 'auto')
      attribute :fill, :string       # Background fill color (RGB hex)
      attribute :theme_fill, :string # Theme color reference (e.g., 'accent1')

      xml do
        element 'shd'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :pattern
        map_attribute 'color', to: :color
        map_attribute 'fill', to: :fill
        map_attribute 'themeFill', to: :theme_fill, render_nil: false
      end
    end
  end
end
