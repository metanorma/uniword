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
        "Arial Black" => "Liberation Sans",
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
        SUBSTITUTIONS[font_name] || registry_substitution(font_name) || font_name
      end

      # Get substitute for a specific script code
      #
      # @param script_code [String] OOXML script code (e.g., "Jpan", "Hans")
      # @param original_typeface [String] Original font name
      # @return [String] OFL typeface name
      def self.substitute_script(script_code, original_typeface)
        registry.dig("per_script", script_code) || substitute(original_typeface)
      end

      # Transform OOXML font scheme with full substitution
      # Handles Latin, EA, CS, and per-script entries
      #
      # @param font_scheme [Drawingml::FontScheme] Font scheme to transform
      # @return [Drawingml::FontScheme] Transformed font scheme
      def self.transform_font_scheme(font_scheme)
        font_scheme.dup.tap do |scheme|
          # Transform major font Latin
          if scheme.major_font_obj&.latin
            scheme.major_font_obj.latin.typeface = substitute(scheme.major_font_obj.latin.typeface)
          end

          # Transform minor font Latin
          if scheme.minor_font_obj&.latin
            scheme.minor_font_obj.latin.typeface = substitute(scheme.minor_font_obj.latin.typeface)
          end
        end
      end

      # Transform friendly FontScheme with full substitution
      # Populates empty EA/CS fields from registry
      #
      # @param friendly [Themes::FontScheme] Friendly font scheme
      # @return [Themes::FontScheme] Transformed font scheme
      def self.transform_friendly_font_scheme(friendly)
        reg = registry
        friendly.tap do |fs|
          fs.major_font = substitute(fs.major_font) if fs.major_font && !fs.major_font.empty?
          fs.minor_font = substitute(fs.minor_font) if fs.minor_font && !fs.minor_font.empty?

          # Populate EA fields if empty
          if fs.major_east_asian.to_s.empty?
            fs.major_east_asian = reg.dig("east_asian", "japanese", "heading")
          else
            fs.major_east_asian = substitute(fs.major_east_asian)
          end
          if fs.minor_east_asian.to_s.empty?
            fs.minor_east_asian = reg.dig("east_asian", "japanese", "body")
          else
            fs.minor_east_asian = substitute(fs.minor_east_asian)
          end

          # Populate CS fields if empty
          if fs.major_complex_script.to_s.empty?
            fs.major_complex_script = reg.dig("complex_script", "arabic", "heading")
          else
            fs.major_complex_script = substitute(fs.major_complex_script)
          end
          if fs.minor_complex_script.to_s.empty?
            fs.minor_complex_script = reg.dig("complex_script", "arabic", "body")
          else
            fs.minor_complex_script = substitute(fs.minor_complex_script)
          end
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

      # Load the OFL font registry
      #
      # @return [Hash] The font registry data
      def self.registry
        @registry ||= begin
          path = File.join(__dir__, "../../../data/resources/font_registry.yml")
          return {} unless File.exist?(path)

          require "yaml"
          YAML.load_file(path)
        end
      end

      # Reset cached registry (useful for testing)
      def self.reset_registry!
        @registry = nil
      end

      class << self
        private

        # Check registry substitutions as fallback
        def registry_substitution(font_name)
          subs = registry["substitutions"]
          subs&.dig(font_name)
        end
      end
    end
  end
end
