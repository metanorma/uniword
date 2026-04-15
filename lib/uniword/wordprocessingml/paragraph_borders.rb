# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Paragraph borders
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:pBdr>
    class ParagraphBorders < Lutaml::Model::Serializable
      attribute :top, Border
      attribute :bottom, Border
      attribute :left, Border
      attribute :right, Border
      attribute :between, Border
      attribute :bar, Border

      xml do
        element "pBdr"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "top", to: :top, render_nil: false
        map_element "bottom", to: :bottom, render_nil: false
        map_element "left", to: :left, render_nil: false
        map_element "right", to: :right, render_nil: false
        map_element "between", to: :between, render_nil: false
        map_element "bar", to: :bar, render_nil: false
      end

      # Create a box-style border (all four sides with same style)
      #
      # @param style [String] Border style
      # @param color [String] Border color (hex)
      # @param size [Integer] Border size
      # @param space [Integer] Border space
      # @return [ParagraphBorders] New borders object with box styling
      def self.box(style:, color:, size: 6, space: 1)
        border = Border.new(val: style, color: color, sz: size, space: space)
        new(top: border, bottom: border, left: border, right: border)
      end

      # Check if this is a box-style border (all four sides present with same style)
      #
      # @return [Boolean] true if box-style
      def box?
        return false unless top && bottom && left && right
        return false unless top.val == bottom.val && top.val == left.val && top.val == right.val
        return false unless top.color == bottom.color && top.color == left.color && top.color == right.color

        true
      end
    end
  end
end
