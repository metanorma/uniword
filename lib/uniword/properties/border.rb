# frozen_string_literal: true

require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Individual border definition for paragraphs, runs, tables, etc.
    # Represents OOXML border properties with style, color, size, and effects
    class Border < Lutaml::Model::Serializable
      xml do
        element :border_element  # Dynamic root based on context
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :style
        map_attribute 'color', to: :color
        map_attribute 'sz', to: :size
        map_attribute 'space', to: :space
        map_attribute 'shadow', to: :shadow
        map_attribute 'frame', to: :frame
      end

      # Border style (single, double, dashed, dotted, thick, thin, etc.)
      # Common values: single, double, dashed, dotted, thick, thin, none
      attribute :style, :string

      # Border color (hex color code, e.g., "FF0000" for red)
      attribute :color, :string

      # Border size in eighths of a point (1-96, where 8 = 1 point)
      attribute :size, :integer

      # Space between border and text in points
      attribute :space, :integer

      # Shadow effect (creates shadow on bottom and right)
      attribute :shadow, :boolean, default: -> { false }

      # Frame effect (creates 3D frame appearance)
      attribute :frame, :boolean, default: -> { false }

      # Convenience method to check if border is visible
      def visible?
        style && style != 'none' && size && size > 0
      end

      # Convenience method to create a simple border
      def self.simple(style = 'single', size = 4, color = 'auto')
        new(style: style, size: size, color: color)
      end

      # Value-based equality
      def ==(other)
        return false unless other.is_a?(self.class)

        style == other.style &&
          color == other.color &&
          size == other.size &&
          space == other.space &&
          shadow == other.shadow &&
          frame == other.frame
      end

      alias eql? ==

      # Hash code for value-based hashing
      def hash
        [style, color, size, space, shadow, frame].hash
      end
    end

    # Paragraph borders container - holds all border types for a paragraph
    class ParagraphBorders < Lutaml::Model::Serializable
      xml do
        element 'pBdr'
        namespace Ooxml::Namespaces::WordProcessingML

        map_element 'top', to: :top
        map_element 'bottom', to: :bottom
        map_element 'left', to: :left
        map_element 'right', to: :right
        map_element 'between', to: :between
        map_element 'bar', to: :bar
      end

      # Top border
      attribute :top, Border

      # Bottom border
      attribute :bottom, Border

      # Left border
      attribute :left, Border

      # Right border
      attribute :right, Border

      # Border between paragraphs (for consecutive paragraphs)
      attribute :between, Border

      # Vertical bar border (used for side borders)
      attribute :bar, Border

      # Convenience method to check if any borders are set
      def any_borders?
        [top, bottom, left, right, between, bar].any? { |border| border&.visible? }
      end

      # Convenience method to set all borders at once
      def set_all_borders(style = 'single', size = 4, color = 'auto')
        border = Border.simple(style, size, color)
        self.top = border
        self.bottom = border
        self.left = border
        self.right = border
      end

      # Convenience method to set individual border
      def set_border(side, style = 'single', size = 4, color = 'auto')
        border = Border.simple(style, size, color)
        case side.to_sym
        when :top
          self.top = border
        when :bottom
          self.bottom = border
        when :left
          self.left = border
        when :right
          self.right = border
        when :between
          self.between = border
        when :bar
          self.bar = border
        else
          raise ArgumentError, "Invalid border side: #{side}. Must be :top, :bottom, :left, :right, :between, or :bar"
        end
      end

      # Value-based equality
      def ==(other)
        return false unless other.is_a?(self.class)

        top == other.top &&
          bottom == other.bottom &&
          left == other.left &&
          right == other.right &&
          between == other.between &&
          bar == other.bar
      end

      alias eql? ==

      # Hash code for value-based hashing
      def hash
        [top, bottom, left, right, between, bar].hash
      end
    end
  end
end