# frozen_string_literal: true

require 'lutaml/model'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Border style enumeration
    #
    # Represents border line styles from OOXML specification
    class BorderStyleValue < Lutaml::Model::Type::String
      xml_namespace Ooxml::Namespaces::WordProcessingML
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

      xml do
        # Element name set dynamically by parent (top, bottom, left, right)
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :style
        map_attribute 'sz', to: :size
        map_attribute 'space', to: :space
        map_attribute 'color', to: :color
      end
    end
  end
end
