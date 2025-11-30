# frozen_string_literal: true

require 'lutaml/model'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Text outline (basic support)
    #
    # Represents <w:textOutline> element with basic outline properties.
    # Full compound/join/cap support planned for v2.0.
    #
    # @example Creating a text outline
    #   outline = TextOutline.new(
    #     width: 12700,
    #     color: '000000'
    #   )
    class TextOutline < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :width, :integer     # Width in EMUs (English Metric Units)
      attribute :color, :string      # RGB hex color

      xml do
        element 'textOutline'
        namespace Ooxml::Namespaces::WordProcessingML

        # Note: Simplified - actual OOXML has nested fill/compound/cap/join elements
        # For now, we store just width and color for basic support
        # Full structure will be added in v2.0
        map_attribute 'width', to: :width
        map_attribute 'color', to: :color
      end
    end
  end
end