# frozen_string_literal: true

module Uniword
  module Themes
    # Applies themes to documents by setting theme data and updating styles
    #
    # When a theme is applied to a document:
    # 1. The theme XML is stored for serialization to word/theme/theme1.xml
    # 2. Document defaults get theme font references (minorAscii, etc.)
    # 3. Heading styles get major font and theme color references
    # 4. Hyperlink styles get theme color references
    class ThemeApplicator
      # Apply theme to document
      #
      # @param theme [Drawingml::Theme] Theme to apply
      # @param document [Wordprocessingml::DocumentRoot] Target document
      # @return [void]
      def apply(theme, document)
        word_theme = normalize_theme(theme)
        document.theme = word_theme.dup
        update_doc_defaults(document, word_theme)
        update_builtin_styles(document, word_theme)
      end

      private

      # Ensure theme is a Drawingml::Theme (convert from friendly if needed)
      def normalize_theme(theme)
        if theme.is_a?(Uniword::Drawingml::Theme)
          theme
        elsif theme.is_a?(Uniword::Themes::Theme)
          Uniword::Themes::ThemeTransformation.new.to_word(theme)
        else
          raise ArgumentError, "Expected Drawingml::Theme or Themes::Theme, got #{theme.class}"
        end
      end

      # Update document defaults to reference theme fonts
      def update_doc_defaults(document, theme)
        return unless theme.font_scheme

        styles_config = document.styles_configuration

        doc_defaults = styles_config.doc_defaults
        if doc_defaults.nil?
          doc_defaults = Uniword::Wordprocessingml::DocDefaults.new
          styles_config.doc_defaults = doc_defaults
        end

        rpr_default = doc_defaults.rPrDefault
        if rpr_default.nil?
          rpr_default = Uniword::Wordprocessingml::RPrDefault.new
          doc_defaults.rPrDefault = rpr_default
        end

        rpr = rpr_default.rPr
        if rpr.nil?
          rpr = Uniword::Wordprocessingml::RunProperties.new
          rpr_default.rPr = rpr
        end

        # Set theme font references on doc defaults (body text = minor font)
        rpr.fonts = build_minor_font_reference(theme)
      end

      # Update built-in heading and hyperlink styles to reference theme
      def update_builtin_styles(document, theme)
        styles_config = document.styles_configuration
        return unless styles_config

        update_heading_styles(styles_config, theme)
        update_hyperlink_style(styles_config, theme)
      end

      # Update heading styles (Heading1-9) with theme font/color references
      def update_heading_styles(styles_config, theme)
        heading_color = theme.color(:dk1)
        (1..9).each do |level|
          style = styles_config.style_by_id("Heading#{level}")
          next unless style

          rpr = style.rPr
          next unless rpr

          # Set major font reference for headings
          rpr.fonts = build_major_font_reference(theme)

          # Set theme color reference for heading text
          if heading_color
            rpr.color = Uniword::Properties::ColorValue.new(
              value: heading_color,
              theme_color: 'text1'
            )
          end
        end
      end

      # Update hyperlink style with theme color reference
      def update_hyperlink_style(styles_config, theme)
        style = styles_config.style_by_id('Hyperlink')
        return unless style

        rpr = style.rPr
        return unless rpr

        hlink_color = theme.color(:hlink)
        if hlink_color
          rpr.color = Uniword::Properties::ColorValue.new(
            value: hlink_color,
            theme_color: 'hyperlink'
          )
        end
      end

      # Build RunFonts referencing the theme's minor (body) font
      def build_minor_font_reference(theme)
        return nil unless theme.font_scheme

        Uniword::Properties::RunFonts.new(
          ascii_theme: 'minorAscii',
          h_ansi_theme: 'minorHAnsi',
          east_asia_theme: 'minorEastAsia',
          cs_theme: 'minorBidi'
        )
      end

      # Build RunFonts referencing the theme's major (heading) font
      def build_major_font_reference(theme)
        return nil unless theme.font_scheme

        Uniword::Properties::RunFonts.new(
          ascii_theme: 'majorAscii',
          h_ansi_theme: 'majorHAnsi',
          east_asia_theme: 'majorEastAsia',
          cs_theme: 'majorBidi'
        )
      end
    end
  end
end
