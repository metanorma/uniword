# frozen_string_literal: true

module Uniword
  module Themes
    # Transforms between FriendlyTheme and WordTheme models.
    #
    # This transformation is bidirectional:
    # - to_word: Themes::Theme → Drawingml::Theme (for document generation)
    # - from_word: Drawingml::Theme → Themes::Theme (for extraction/editing)
    #
    # Architecture:
    # - Stateless transformation (no instance state)
    # - Follows Transformation pattern from lutaml-model
    # - Separates concerns: models own serialization, this class owns conversion
    #
    # @example Convert friendly theme to Word theme
    #   transformation = ThemeTransformation.new
    #   word_theme = transformation.to_word(friendly_theme)
    #
    # @example Extract friendly theme from Word theme
    #   friendly = transformation.from_word(word_theme)
    #
    # @example Full roundtrip
    #   word_theme = transformation.to_word(friendly)
    #   extracted = transformation.from_word(word_theme)
    #   friendly.to_yaml == extracted.to_yaml  # => true (semantically)
    class ThemeTransformation
      # Standard color keys in a theme
      COLOR_KEYS = %i[dk1 lt1 dk2 lt2 accent1 accent2 accent3 accent4 accent5 accent6 hlink
                      fol_hlink].freeze

      # Transform friendly theme to Word theme
      #
      # @param friendly_theme [Themes::Theme] The friendly theme
      # @return [Drawingml::Theme] The Word theme (OOXML model)
      def to_word(friendly_theme)
        Drawingml::Theme.new(
          name: friendly_theme.name,
          theme_elements: build_theme_elements(friendly_theme),
        )
      end

      # Transform Word theme to friendly theme
      #
      # @param word_theme [Drawingml::Theme] The Word theme (OOXML model)
      # @return [Themes::Theme] The friendly theme
      def from_word(word_theme)
        Theme.new(
          name: word_theme.name,
          color_scheme: extract_color_scheme(word_theme),
          font_scheme: extract_font_scheme(word_theme),
        )
      end

      private

      OFFICE_THEME_PATH = File.expand_path("../../../data/themes/office_theme.xml", __dir__).freeze

      def default_format_scheme
        @default_format_scheme ||= begin
          theme = Drawingml::Theme.from_xml(File.read(OFFICE_THEME_PATH))
          theme.theme_elements.fmt_scheme
        end
      end

      # Build OOXML ThemeElements from friendly theme
      #
      # @param friendly [Themes::Theme] Friendly theme
      # @return [Drawingml::ThemeElements] OOXML theme elements
      def build_theme_elements(friendly)
        return nil unless friendly

        Drawingml::ThemeElements.new(
          clr_scheme: build_color_scheme(friendly.color_scheme),
          font_scheme: build_font_scheme(friendly.font_scheme),
          fmt_scheme: default_format_scheme,
        )
      end

      # Build OOXML ColorScheme from friendly color scheme
      #
      # @param friendly_colors [Themes::ColorScheme, nil] Friendly color scheme
      # @return [Drawingml::ColorScheme, nil] OOXML color scheme
      def build_color_scheme(friendly_colors)
        return nil unless friendly_colors

        Drawingml::ColorScheme.new(
          name: friendly_colors.name,
          dk1: build_color_reference(friendly_colors[:dk1], Drawingml::Dk1Color),
          lt1: build_color_reference(friendly_colors[:lt1], Drawingml::Lt1Color),
          dk2: build_color_reference(friendly_colors[:dk2], Drawingml::Dk2Color),
          lt2: build_color_reference(friendly_colors[:lt2], Drawingml::Lt2Color),
          accent1: build_color_reference(friendly_colors[:accent1], Drawingml::Accent1Color),
          accent2: build_color_reference(friendly_colors[:accent2], Drawingml::Accent2Color),
          accent3: build_color_reference(friendly_colors[:accent3], Drawingml::Accent3Color),
          accent4: build_color_reference(friendly_colors[:accent4], Drawingml::Accent4Color),
          accent5: build_color_reference(friendly_colors[:accent5], Drawingml::Accent5Color),
          accent6: build_color_reference(friendly_colors[:accent6], Drawingml::Accent6Color),
          hlink: build_color_reference(friendly_colors[:hlink], Drawingml::HlinkColor),
          fol_hlink: build_color_reference(friendly_colors[:fol_hlink], Drawingml::FolHlinkColor),
        )
      end

      # Build OOXML color reference from hex value
      #
      # Creates the appropriate color type (Dk1Color, Lt1Color, etc.)
      # with srgb_clr attribute set
      #
      # @param hex [String, nil] Hex color value (e.g., "F81B02")
      # @param color_class [Class] The specific color class (Dk1Color, Lt1Color, etc.)
      # @return [Object, nil] Color reference object
      def build_color_reference(hex, color_class)
        return nil unless hex

        # Create the color type and use the rgb= helper from ThemeColorBase
        color_class.new.tap { |c| c.rgb = hex }
      end

      # Build OOXML FontScheme from friendly font scheme
      #
      # @param friendly_fonts [Themes::FontScheme, nil] Friendly font scheme
      # @return [Drawingml::FontScheme, nil] OOXML font scheme
      def build_font_scheme(friendly_fonts)
        return nil unless friendly_fonts

        Drawingml::FontScheme.new(
          name: friendly_fonts.name,
          major_font_obj: build_major_font(friendly_fonts),
          minor_font_obj: build_minor_font(friendly_fonts),
        )
      end

      # Build OOXML MajorFont from friendly font scheme
      #
      # @param friendly [Themes::FontScheme] Friendly font scheme
      # @return [Drawingml::MajorFont] OOXML major font
      def build_major_font(friendly)
        script_fonts = build_script_fonts(friendly.per_script)
        Drawingml::MajorFont.new(
          latin: Drawingml::LatinFont.new(typeface: friendly.major_font || ""),
          ea: Drawingml::EaFont.new(typeface: friendly.major_east_asian || ""),
          cs: Drawingml::CsFont.new(typeface: friendly.major_complex_script || ""),
          fonts: script_fonts,
        )
      end

      # Build OOXML MinorFont from friendly font scheme
      #
      # @param friendly [Themes::FontScheme] Friendly font scheme
      # @return [Drawingml::MinorFont] OOXML minor font
      def build_minor_font(friendly)
        script_fonts = build_script_fonts(friendly.per_script)
        Drawingml::MinorFont.new(
          latin: Drawingml::LatinFont.new(typeface: friendly.minor_font || ""),
          ea: Drawingml::EaFont.new(typeface: friendly.minor_east_asian || ""),
          cs: Drawingml::CsFont.new(typeface: friendly.minor_complex_script || ""),
          fonts: script_fonts,
        )
      end

      # Build ScriptFont entries from per_script hash
      #
      # @param per_script [Hash, nil] Script code → typeface mapping
      # @return [Array<Drawingml::ScriptFont>] Script font entries
      def build_script_fonts(per_script)
        return [] unless per_script.is_a?(Hash)

        per_script.map do |script, typeface|
          Drawingml::ScriptFont.new(script: script, typeface: typeface)
        end
      end

      # Extract friendly color scheme from Word theme
      #
      # @param word_theme [Drawingml::Theme] Word theme
      # @return [Themes::ColorScheme, nil] Friendly color scheme
      def extract_color_scheme(word_theme)
        word_colors = word_theme.theme_elements&.clr_scheme
        return nil unless word_colors

        colors = {}
        COLOR_KEYS.each do |key|
          if (color_ref = word_colors.send(key))
            colors[key] = extract_hex_color(color_ref)
          end
        end

        ColorScheme.new(
          name: word_colors.name,
          colors: colors,
        )
      end

      # Extract hex color from OOXML color reference
      #
      # @param color_ref [Object] OOXML color reference (Dk1Color, etc.)
      # @return [String, nil] Hex color value
      def extract_hex_color(color_ref)
        return nil unless color_ref.is_a?(Drawingml::ThemeColorBase)

        if color_ref.srgb_clr
          color_ref.srgb_clr.val
        elsif color_ref.sys_clr
          color_ref.sys_clr.val
        end
      end

      # Extract friendly font scheme from Word theme
      #
      # @param word_theme [Drawingml::Theme] Word theme
      # @return [Themes::FontScheme, nil] Friendly font scheme
      def extract_font_scheme(word_theme)
        word_fonts = word_theme.theme_elements&.font_scheme
        return nil unless word_fonts

        FontScheme.new(
          name: word_fonts.name,
          major_font: word_fonts.major_font_obj&.latin&.typeface,
          minor_font: word_fonts.minor_font_obj&.latin&.typeface,
          major_east_asian: word_fonts.major_font_obj&.ea&.typeface,
          major_complex_script: word_fonts.major_font_obj&.cs&.typeface,
          minor_east_asian: word_fonts.minor_font_obj&.ea&.typeface,
          minor_complex_script: word_fonts.minor_font_obj&.cs&.typeface,
        )
      end
    end
  end
end
