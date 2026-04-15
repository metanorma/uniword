# frozen_string_literal: true

module Uniword
  module Resource
    # SERVICE for color transformations
    # Pure functions - no state, no side effects
    class ColorTransformer
      # Shift ranges (in HSL)
      HUE_SHIFT_RANGE = (-15..15)
      SATURATION_SHIFT_RANGE = (-10..10)
      LIGHTNESS_SHIFT_RANGE = (-10..10)

      # Transform a hex color by shifting HSL values
      #
      # @param hex_color [String] Hex color code (e.g., "#FF0000" or "FF0000")
      # @param hue_shift [Integer] Hue shift in degrees (-15..15)
      # @param saturation_shift [Integer] Saturation shift percent (-10..10)
      # @param lightness_shift [Integer] Lightness shift percent (-10..10)
      # @return [String] Transformed hex color
      def self.shift_color(hex_color, hue_shift:, saturation_shift:, lightness_shift:)
        return hex_color if hue_shift.zero? && saturation_shift.zero? && lightness_shift.zero?

        rgb = hex_to_rgb(hex_color)
        hsl = rgb_to_hsl(rgb)

        # Apply shifts with clamping
        hsl[:h] = (hsl[:h] + hue_shift) % 360
        hsl[:s] = (hsl[:s] + saturation_shift).clamp(0, 100)
        hsl[:l] = (hsl[:l] + lightness_shift).clamp(0, 100)

        rgb_to_hex(hsl_to_rgb(hsl))
      end

      # Transform all colors in a color scheme
      #
      # @param color_scheme [Themes::ColorScheme] Color scheme to transform
      # @param hue_shift [Integer] Hue shift in degrees
      # @param saturation_shift [Integer] Saturation shift percent
      # @param lightness_shift [Integer] Lightness shift percent
      # @return [Themes::ColorScheme] Transformed color scheme
      def self.transform_color_scheme(color_scheme, hue_shift:, saturation_shift:, lightness_shift:)
        color_scheme.dup.tap do |scheme|
          # Transform each color in the scheme
          scheme.colors&.each_value do |color|
            next unless color.respond_to?(:val) && color.val&.match?(/^[0-9A-Fa-f]{6}$/)

            color.val = shift_color(
              color.val,
              hue_shift:,
              saturation_shift:,
              lightness_shift:
            )
          end
        end
      end

      # Convert hex color to RGB hash
      #
      # @param hex [String] Hex color code
      # @return [Hash] RGB hash with :r, :g, :b keys
      def self.hex_to_rgb(hex)
        hex = hex.sub(/^#/, "")
        { r: hex[0..1].to_i(16), g: hex[2..3].to_i(16), b: hex[4..5].to_i(16) }
      end

      # Convert RGB hash to hex color
      #
      # @param rgb [Hash] RGB hash with :r, :g, :b keys
      # @return [String] Hex color code with # prefix
      def self.rgb_to_hex(rgb)
        format("#%02X%02X%02X", rgb[:r], rgb[:g], rgb[:b])
      end

      # Convert RGB to HSL
      #
      # @param rgb [Hash] RGB hash with :r, :g, :b keys (0-255)
      # @return [Hash] HSL hash with :h (0-360), :s (0-100), :l (0-100)
      def self.rgb_to_hsl(rgb)
        r = rgb[:r] / 255.0
        g = rgb[:g] / 255.0
        b = rgb[:b] / 255.0
        max = [r, g, b].max
        min = [r, g, b].min
        l = (max + min) / 2.0

        if max == min
          h = s = 0
        else
          d = max - min
          s = l > 0.5 ? d / (2 - max - min) : d / (max + min)
          h = case max
              when r then (((g - b) / d) + (g < b ? 6 : 0)) * 60
              when g then (((b - r) / d) + 2) * 60
              when b then (((r - g) / d) + 4) * 60
              end
        end

        { h: h.round, s: (s * 100).round, l: (l * 100).round }
      end

      # Convert HSL to RGB
      #
      # @param hsl [Hash] HSL hash with :h (0-360), :s (0-100), :l (0-100)
      # @return [Hash] RGB hash with :r, :g, :b keys (0-255)
      def self.hsl_to_rgb(hsl)
        h = hsl[:h]
        s = hsl[:s] / 100.0
        l = hsl[:l] / 100.0

        if s.zero?
          r = g = b = l
        else
          hue_to_rgb = lambda do |p, q, t|
            t += 1 if t.negative?
            t -= 1 if t > 1
            return p + ((q - p) * 6 * t) if t < 1 / 6.0
            return q if t < 1 / 2.0
            return p + ((q - p) * ((2 / 3.0) - t) * 6) if t < 2 / 3.0

            p
          end

          q = l < 0.5 ? l * (1 + s) : l + s - (l * s)
          p = (2 * l) - q
          r = hue_to_rgb.call(p, q, (h / 360.0) + (1 / 3.0))
          g = hue_to_rgb.call(p, q, h / 360.0)
          b = hue_to_rgb.call(p, q, (h / 360.0) - (1 / 3.0))
        end

        { r: (r * 255).round, g: (g * 255).round, b: (b * 255).round }
      end
    end
  end
end
