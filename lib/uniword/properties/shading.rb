# frozen_string_literal: true

require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Paragraph shading properties
    # Represents background fill and pattern shading for paragraphs
    class ParagraphShading < Lutaml::Model::Serializable
      xml do
        element 'shd'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :shading_type
        map_attribute 'color', to: :color
        map_attribute 'fill', to: :fill
        map_attribute 'themeFill', to: :theme_fill
        map_attribute 'themeFillShade', to: :theme_fill_shade
        map_attribute 'themeFillTint', to: :theme_fill_tint
        map_attribute 'themeColor', to: :theme_color
        map_attribute 'themeShade', to: :theme_shade
        map_attribute 'themeTint', to: :theme_tint
      end

      # Shading pattern type (clear, solid, pct5, pct10, etc.)
      # Common values: clear, solid, pct5, pct10, pct12, pct15, pct20, pct25, pct30, pct35, pct37, pct40, pct45, pct50, pct55, pct60, pct62, pct65, pct70, pct75, pct80, pct85, pct87, pct90, pct95
      attribute :shading_type, :string, default: -> { 'clear' }

      # Foreground color for pattern (hex color code)
      attribute :color, :string

      # Background fill color (hex color code)
      attribute :fill, :string

      # Theme color for fill
      attribute :theme_fill, :string

      # Theme fill shade (0-255, where 255 = 100% shade)
      attribute :theme_fill_shade, :string

      # Theme fill tint (0-255, where 255 = 100% tint)
      attribute :theme_fill_tint, :string

      # Theme color for pattern
      attribute :theme_color, :string

      # Theme shade for pattern (0-255)
      attribute :theme_shade, :string

      # Theme tint for pattern (0-255)
      attribute :theme_tint, :string

      # Convenience method to create solid color shading
      def self.solid(color)
        new(shading_type: 'solid', fill: color)
      end

      # Convenience method to create clear (no) shading
      def self.clear
        new(shading_type: 'clear')
      end

      # Convenience method to create percentage pattern shading
      def self.percentage(percent, color = 'auto', fill = 'auto')
        pattern = case percent
                  when 5 then 'pct5'
                  when 10 then 'pct10'
                  when 12 then 'pct12'
                  when 15 then 'pct15'
                  when 20 then 'pct20'
                  when 25 then 'pct25'
                  when 30 then 'pct30'
                  when 35 then 'pct35'
                  when 37 then 'pct37'
                  when 40 then 'pct40'
                  when 45 then 'pct45'
                  when 50 then 'pct50'
                  when 55 then 'pct55'
                  when 60 then 'pct60'
                  when 62 then 'pct62'
                  when 65 then 'pct65'
                  when 70 then 'pct70'
                  when 75 then 'pct75'
                  when 80 then 'pct80'
                  when 85 then 'pct85'
                  when 87 then 'pct87'
                  when 90 then 'pct90'
                  when 95 then 'pct95'
                  else 'pct50' # Default to 50%
                  end
        new(shading_type: pattern, color: color, fill: fill)
      end

      # Check if this is clear (no) shading
      def clear?
        shading_type == 'clear'
      end

      # Check if this is solid shading
      def solid?
        shading_type == 'solid'
      end

      # Get the effective background color
      def background_color
        fill || theme_fill
      end

      # Value-based equality
      def ==(other)
        return false unless other.is_a?(self.class)

        shading_type == other.shading_type &&
          color == other.color &&
          fill == other.fill &&
          theme_fill == other.theme_fill &&
          theme_fill_shade == other.theme_fill_shade &&
          theme_fill_tint == other.theme_fill_tint &&
          theme_color == other.theme_color &&
          theme_shade == other.theme_shade &&
          theme_tint == other.theme_tint
      end

      alias eql? ==

      # Hash code for value-based hashing
      def hash
        [shading_type, color, fill, theme_fill, theme_fill_shade, theme_fill_tint, theme_color, theme_shade, theme_tint].hash
      end
    end

    # Run shading properties (similar to paragraph but for text runs)
    class RunShading < Lutaml::Model::Serializable
      xml do
        element 'shd'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :shading_type
        map_attribute 'color', to: :color
        map_attribute 'fill', to: :fill
        map_attribute 'themeFill', to: :theme_fill
        map_attribute 'themeFillShade', to: :theme_fill_shade
        map_attribute 'themeFillTint', to: :theme_fill_tint
      end

      # Shading pattern type
      attribute :shading_type, :string, default: -> { 'clear' }

      # Foreground color for pattern
      attribute :color, :string

      # Background fill color
      attribute :fill, :string

      # Theme color for fill
      attribute :theme_fill, :string

      # Theme fill shade
      attribute :theme_fill_shade, :string

      # Theme fill tint
      attribute :theme_fill_tint, :string

      # Convenience method to create solid color shading
      def self.solid(color)
        new(shading_type: 'solid', fill: color)
      end

      # Convenience method to create clear (no) shading
      def self.clear
        new(shading_type: 'clear')
      end

      # Value-based equality
      def ==(other)
        return false unless other.is_a?(self.class)

        shading_type == other.shading_type &&
          color == other.color &&
          fill == other.fill &&
          theme_fill == other.theme_fill &&
          theme_fill_shade == other.theme_fill_shade &&
          theme_fill_tint == other.theme_fill_tint
      end

      alias eql? ==

      # Hash code for value-based hashing
      def hash
        [shading_type, color, fill, theme_fill, theme_fill_shade, theme_fill_tint].hash
      end
    end
  end
end