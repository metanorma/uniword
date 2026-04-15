# frozen_string_literal: true

module Uniword
  module Resource
    # SERVICE for font substitution
    # Pure functions - no state, no side effects
    class FontSubstitutor
      # Font substitution map (MS fonts -> open-source alternatives)
      SUBSTITUTIONS = {
        "Calibri" => "Carlito",
        "Calibri Light" => "Carlito",
        "Cambria" => "Caladea",
        "Cambria Math" => "Caladea",
        "Arial" => "Liberation Sans",
        "Times New Roman" => "Liberation Serif",
        "Courier New" => "Liberation Mono",
        "Segoe UI" => "Source Sans Pro",
        "Tahoma" => "Liberation Sans"
      }.freeze

      # Get substitute font name
      #
      # @param font_name [String] Original font name
      # @return [String] Substituted font name or original if no substitution
      def self.substitute(font_name)
        SUBSTITUTIONS[font_name] || font_name
      end

      # Transform font scheme with substitutions
      #
      # @param font_scheme [Drawingml::FontScheme] Font scheme to transform
      # @return [Drawingml::FontScheme] Transformed font scheme
      def self.transform_font_scheme(font_scheme)
        font_scheme.dup.tap do |scheme|
          # Transform major font
          scheme.major_font_obj.latin.typeface = substitute(scheme.major_font_obj.latin.typeface) if scheme.major_font_obj&.latin

          # Transform minor font
          scheme.minor_font_obj.latin.typeface = substitute(scheme.minor_font_obj.latin.typeface) if scheme.minor_font_obj&.latin
        end
      end

      # Check font availability via Fontist
      #
      # @param font_name [String] Font name to check
      # @return [Boolean] true if font is available or Fontist is not installed
      def self.check_availability(font_name)
        return true unless defined?(Fontist)

        Fontist.available?(font_name)
      rescue StandardError
        false
      end
    end
  end
end
