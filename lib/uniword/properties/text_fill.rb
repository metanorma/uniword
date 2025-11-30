# frozen_string_literal: true

require 'lutaml/model'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Text fill (basic solid color support)
    #
    # Represents <w:textFill> element with solid color fill.
    # Full gradient/pattern support planned for v2.0.
    #
    # @example Creating a text fill
    #   fill = TextFill.new(color: 'FF0000')
    class TextFill < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :color, :string      # RGB hex color for solid fill

      xml do
        element 'textFill'
        namespace Ooxml::Namespaces::WordProcessingML

        # Note: Simplified - actual OOXML has nested solidFill/gradFill elements
        # For now, we store just the color value for basic support
        # Full structure will be added in v2.0
        map_attribute 'color', to: :color
      end

      # Initialize from color value
      def initialize(attrs = {})
        if attrs.is_a?(String)
          super(color: attrs)
        else
          super
        end
      end
    end
  end
end