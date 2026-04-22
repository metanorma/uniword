# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    class RunProperties < Lutaml::Model::Serializable
      # Initialization and primitive-to-wrapper conversion for RunProperties.
      #
      # Handles the bridging between convenience constructors
      # (e.g., RunProperties.new(bold: true)) and the wrapper
      # objects (e.g., Properties::Bold) required by lutaml-model.
      module Conversion
        def initialize(attrs = {})
          # Extract flat convenience keys before super (lutaml-model ignores
          # unknown keys). These are converted to proper wrapper objects below.
          font_val = attrs.delete(:font) || attrs.delete("font")
          font_ascii_val = attrs.delete(:font_ascii) || attrs.delete("font_ascii")
          font_ea_val = attrs.delete(:font_east_asia) || attrs.delete("font_east_asia")
          font_ha_val = attrs.delete(:font_h_ansi) || attrs.delete("font_h_ansi")
          font_cs_val = attrs.delete(:font_cs) || attrs.delete("font_cs")
          lang_val = attrs.delete(:language_val) || attrs.delete("language_val")
          lang_ea = attrs.delete(:language_east_asia) || attrs.delete("language_east_asia")
          lang_bidi = attrs.delete(:language_bidi) || attrs.delete("language_bidi")
          raw_language = extract_raw_language(attrs)
          shading_fill_val = attrs.delete(:shading_fill) || attrs.delete("shading_fill")
          shading_type_val = attrs.delete(:shading_type) || attrs.delete("shading_type")

          super

          convert_primitive_attributes!
          apply_font_overrides(font_val, font_ascii_val, font_ea_val,
                               font_ha_val, font_cs_val)
          apply_language_overrides(lang_val, lang_ea, lang_bidi, raw_language)
          apply_shading_overrides(shading_fill_val, shading_type_val)
        end

        # Convert primitive attribute values to proper wrapper objects.
        # Called after super() to handle cases where primitives were passed
        # instead of the expected Serializable wrapper types.
        def convert_primitive_attributes!
          convert_boolean_attrs!
          convert_style_attr!
          convert_size_attrs!
          convert_color_attr!
          convert_underline_attr!
          convert_highlight_attr!
          convert_vertical_align_attr!
          convert_simple_wrapper_attrs!
          convert_text_effect_attrs!
        end

        private

        def extract_raw_language(attrs)
          raw = attrs[:language] || attrs["language"]
          return unless raw.is_a?(String)

          attrs.delete(:language)
          attrs.delete("language")
          raw
        end

        def apply_font_overrides(font_val, font_ascii_val, font_ea_val,
                                 font_ha_val, font_cs_val)
          if font_val || font_ascii_val
            self.fonts ||= Properties::RunFonts.new
            fonts.ascii = font_ascii_val || font_val
          end
          if font_ea_val
            self.fonts ||= Properties::RunFonts.new
            fonts.east_asia = font_ea_val
          end
          if font_ha_val
            self.fonts ||= Properties::RunFonts.new
            fonts.h_ansi = font_ha_val
          end
          return unless font_cs_val

          self.fonts ||= Properties::RunFonts.new
          fonts.cs = font_cs_val
        end

        def apply_language_overrides(lang_val, lang_ea, lang_bidi, raw_language)
          return unless lang_val || lang_ea || lang_bidi || raw_language

          self.language = Properties::Language.new
          language.val = lang_val || raw_language if lang_val || raw_language
          language.east_asia = lang_ea if lang_ea
          language.bidi = lang_bidi if lang_bidi
        end

        def apply_shading_overrides(fill_val, type_val)
          return unless fill_val || type_val

          self.shading ||= Properties::Shading.new
          shading.fill = fill_val if fill_val
          shading.pattern = type_val if type_val
        end

        def convert_boolean_attrs!
          @bold = Properties::Bold.new(value: @bold) if @bold && !@bold.is_a?(Properties::Bold)
          @bold_cs = Properties::BoldCs.new(value: @bold_cs) if @bold_cs && !@bold_cs.is_a?(Properties::BoldCs)
          @italic = Properties::Italic.new(value: @italic) if @italic && !@italic.is_a?(Properties::Italic)
          @italic_cs = Properties::ItalicCs.new(value: @italic_cs) if @italic_cs && !@italic_cs.is_a?(Properties::ItalicCs)
          @strike = Properties::Strike.new(value: @strike) if @strike && !@strike.is_a?(Properties::Strike)
          @double_strike = Properties::DoubleStrike.new(value: @double_strike) if @double_strike && !@double_strike.is_a?(Properties::DoubleStrike)
          @small_caps = Properties::SmallCaps.new(value: @small_caps) if @small_caps && !@small_caps.is_a?(Properties::SmallCaps)
          @caps = Properties::Caps.new(value: @caps) if @caps && !@caps.is_a?(Properties::Caps)
          @hidden = Properties::Vanish.new(value: @hidden) if @hidden && !@hidden.is_a?(Properties::Vanish)
        end

        def convert_style_attr!
          @style = Properties::RunStyleReference.new(value: @style) if @style.is_a?(String)
        end

        def convert_size_attrs!
          if @size && !@size.is_a?(Properties::FontSize)
            val = @size.is_a?(Numeric) ? @size : @size.to_i
            @size = Properties::FontSize.new(value: val)
          end
          return unless @size_cs && !@size_cs.is_a?(Properties::FontSize)

          val = @size_cs.is_a?(Numeric) ? @size_cs : @size_cs.to_i
          @size_cs = Properties::FontSize.new(value: val)
        end

        def convert_color_attr!
          @color = Properties::ColorValue.new(value: @color.to_s) if @color && !@color.is_a?(Properties::ColorValue)
        end

        def convert_underline_attr!
          return unless @underline && !@underline.is_a?(Properties::Underline)

          @underline = if @underline == true || @underline == "single"
                         Properties::Underline.new(value: "single")
                       elsif @underline.is_a?(String)
                         Properties::Underline.new(value: @underline)
                       else
                         Properties::Underline.new(value: @underline.to_s)
                       end
        end

        def convert_highlight_attr!
          @highlight = Properties::Highlight.new(value: @highlight.to_s) if @highlight && !@highlight.is_a?(Properties::Highlight)
        end

        def convert_vertical_align_attr!
          @vertical_align = Properties::VerticalAlign.new(value: @vertical_align.to_s) if @vertical_align && !@vertical_align.is_a?(Properties::VerticalAlign)
        end

        def convert_simple_wrapper_attrs!
          @position = Properties::Position.new(value: @position) if @position && !@position.is_a?(Properties::Position)
          @character_spacing = Properties::CharacterSpacing.new(value: @character_spacing) if @character_spacing && !@character_spacing.is_a?(Properties::CharacterSpacing)
          @kerning = Properties::Kerning.new(value: @kerning) if @kerning && !@kerning.is_a?(Properties::Kerning)
          @width_scale = Properties::WidthScale.new(value: @width_scale) if @width_scale && !@width_scale.is_a?(Properties::WidthScale)
          @emphasis_mark = Properties::EmphasisMark.new(value: @emphasis_mark.to_s) if @emphasis_mark && !@emphasis_mark.is_a?(Properties::EmphasisMark)
        end

        def convert_text_effect_attrs!
          @text_fill = Properties::TextFill.new if @text_fill && !@text_fill.is_a?(Properties::TextFill)
          return unless @text_outline && !@text_outline.is_a?(Properties::TextOutline)

          @text_outline = Properties::TextOutline.new
        end
      end
    end
  end
end
