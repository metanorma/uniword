# frozen_string_literal: true

require 'digest'

module Uniword
  module Resource
    # MODEL for processing themes into copyright-free variants
    # Has state (shift values) and behavior (process)
    class ThemeProcessor
      attr_reader :hue_shift, :saturation_shift, :lightness_shift

      # Shift ranges for random generation
      HUE_SHIFT_RANGE = (-10..10).freeze
      SATURATION_SHIFT_RANGE = (-5..5).freeze
      LIGHTNESS_SHIFT_RANGE = (-5..5).freeze

      # Create processor with optional shift values
      #
      # @param hue_shift [Integer, nil] Hue shift in degrees (random if nil)
      # @param saturation_shift [Integer, nil] Saturation shift percent (random if nil)
      # @param lightness_shift [Integer, nil] Lightness shift percent (random if nil)
      def initialize(hue_shift: nil, saturation_shift: nil, lightness_shift: nil)
        @hue_shift = hue_shift || rand(HUE_SHIFT_RANGE)
        @saturation_shift = saturation_shift || rand(SATURATION_SHIFT_RANGE)
        @lightness_shift = lightness_shift || rand(LIGHTNESS_SHIFT_RANGE)
      end

      # Create deterministic processor from seed string
      #
      # @param seed [String] Seed string for deterministic shift generation
      # @return [ThemeProcessor] Processor with deterministic shift values
      def self.from_seed(seed)
        hash = Digest::SHA256.hexdigest(seed)

        # Use first 24 hex chars (6 bytes each) for shift values
        hue_shift = (hash[0, 6].to_i(16) % 21) - 10  # -10..10
        saturation_shift = (hash[6, 6].to_i(16) % 11) - 5  # -5..5
        lightness_shift = (hash[12, 6].to_i(16) % 11) - 5  # -5..5

        new(
          hue_shift: hue_shift,
          saturation_shift: saturation_shift,
          lightness_shift: lightness_shift
        )
      end

      # Create identity processor (no transformations)
      #
      # @return [ThemeProcessor] Processor with zero shifts
      def self.identity
        new(hue_shift: 0, saturation_shift: 0, lightness_shift: 0)
      end

      # Check if this processor is an identity (no-op)
      #
      # @return [Boolean] true if all shifts are zero
      def identity?
        hue_shift.zero? && saturation_shift.zero? && lightness_shift.zero?
      end

      # Process a theme into a copyright-free variant
      #
      # @param theme [Drawingml::Theme] Theme to process
      # @return [Drawingml::Theme] Processed theme with shifted colors and substituted fonts
      def process(theme)
        theme.dup.tap do |processed|
          # Transform color scheme
          if processed.theme_elements&.clr_scheme
            transform_color_scheme(processed.theme_elements.clr_scheme)
          end

          # Transform font scheme
          if processed.theme_elements&.font_scheme
            FontSubstitutor.transform_font_scheme(processed.theme_elements.font_scheme)
          end

          # Update name to indicate it's a Uniword variant
          processed.name = "#{theme.name} (Uniword)"
        end
      end

      private

      # Transform color scheme by shifting all colors
      #
      # @param color_scheme [Drawingml::ColorScheme] Color scheme to transform
      def transform_color_scheme(color_scheme)
        # Get all color attributes that respond to srgb_clr
        color_attrs = %i[dk1 lt1 dk2 lt2 accent1 accent2 accent3 accent4 accent5 accent6 hlink fol_hlink]

        color_attrs.each do |attr|
          color_obj = color_scheme.send(attr)
          next unless color_obj&.srgb_clr&.val

          original = color_obj.srgb_clr.val
          color_obj.srgb_clr.val = ColorTransformer.shift_color(
            original,
            hue_shift: hue_shift,
            saturation_shift: saturation_shift,
            lightness_shift: lightness_shift
          )
        end
      end
    end
  end
end
