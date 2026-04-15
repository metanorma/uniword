# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Border style enumeration
    #
    # Represents border line styles from OOXML specification
    class BorderStyleValue < Lutaml::Model::Type::String
    end

    # Individual border definition
    #
    # Represents a single border (top, bottom, left, right) with style,
    # size, spacing, and color attributes.
    #
    # @example Creating a border
    #   border = Border.new(
    #     style: 'single',
    #     size: 4,
    #     space: 1,
    #     color: 'auto'
    #   )
    class Border < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :style, BorderStyleValue
      attribute :size, :integer      # Size in eighths of a point (1-96)
      attribute :space, :integer     # Spacing offset in points (0-31)
      attribute :color, :string      # RGB hex or 'auto'
      attribute :theme_color, :string
      attribute :theme_shade, :string

      xml do
        # Use 'border' as element name for standalone parsing
        element "border"
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :style
        map_attribute "sz", to: :size
        map_attribute "space", to: :space
        map_attribute "color", to: :color
        map_attribute "themeColor", to: :theme_color
        map_attribute "themeShade", to: :theme_shade
      end
    end
  end
end
