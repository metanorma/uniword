# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Shading pattern
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:shd>
    class Shading < Lutaml::Model::Serializable
      attribute :val, :string
      attribute :color, :string
      attribute :fill, :string
      attribute :theme_fill, :string
      attribute :theme_color, :string

      xml do
        element 'shd'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
        map_attribute 'color', to: :color
        map_attribute 'fill', to: :fill
        map_attribute 'themeFill', to: :theme_fill
        map_attribute 'themeColor', to: :theme_color
      end

      # Alias for val (API compatibility)
      #
      # @return [String] The shading pattern type
      def pattern
        val
      end

      # Alias for val (API compatibility)
      #
      # @param value [String] The shading pattern type
      def pattern=(value)
        self.val = value
      end

      # Alias for val (API compatibility)
      #
      # @return [String] The shading type
      def type
        val
      end

      # Alias for val (API compatibility)
      #
      # @param value [String] The shading type
      def type=(value)
        self.val = value
      end

      # Alias for val (API compatibility)
      #
      # @return [String] The shading type
      def shading_type
        val
      end

      # Alias for val (API compatibility)
      #
      # @param value [String] The shading type
      def shading_type=(value)
        self.val = value
      end

      # Alias for fill (API compatibility)
      #
      # @return [String] The background fill color
      def shading_fill
        fill
      end

      # Alias for fill (API compatibility)
      #
      # @param value [String] The background fill color
      def shading_fill=(value)
        self.fill = value
      end

      # Alias for color (API compatibility)
      #
      # @return [String] The foreground/pattern color
      def shading_color
        color
      end

      # Alias for color (API compatibility)
      #
      # @param value [String] The foreground/pattern color
      def shading_color=(value)
        self.color = value
      end
    end
  end
end
