# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    class RunProperties < Lutaml::Model::Serializable
      # YAML serialization transforms for RunProperties.
      #
      # Handles bidirectional conversion between flat YAML keys
      # (bold, italic, size, etc.) and the wrapper objects used
      # internally by the OOXML model.
      #
      # Every writer assigns through YamlWriter#yaml_put; see that module
      # for why.
      module YamlTransforms
        include YamlWriter

        # --- Boolean transforms ---
        #
        # Toggles read through BooleanElement#on?, the same reading the XML
        # and predicate consumers get.

        def yaml_bold_from(instance, value)
          instance.bold = Properties::Bold.new(value: value) unless value.nil?
        end

        def yaml_bold_to(instance, doc)
          yaml_put(doc, "bold", instance.bold&.on?)
        end

        def yaml_italic_from(instance, value)
          instance.italic = Properties::Italic.new(value: value) unless value.nil?
        end

        def yaml_italic_to(instance, doc)
          yaml_put(doc, "italic", instance.italic&.on?)
        end

        def yaml_strike_from(instance, value)
          instance.strike = Properties::Strike.new(value: value) unless value.nil?
        end

        def yaml_strike_to(instance, doc)
          yaml_put(doc, "strike", instance.strike&.on?)
        end

        def yaml_double_strike_from(instance, value)
          instance.double_strike = Properties::DoubleStrike.new(value: value) unless value.nil?
        end

        def yaml_double_strike_to(instance, doc)
          yaml_put(doc, "double_strike", instance.double_strike&.on?)
        end

        def yaml_small_caps_from(instance, value)
          instance.small_caps = Properties::SmallCaps.new(value: value) unless value.nil?
        end

        def yaml_small_caps_to(instance, doc)
          yaml_put(doc, "small_caps", instance.small_caps&.on?)
        end

        def yaml_caps_from(instance, value)
          instance.caps = Properties::Caps.new(value: value) unless value.nil?
        end

        # "caps" and "all_caps" are two spellings of one property, so both
        # rules write the canonical key rather than emitting it twice.
        def yaml_caps_to(instance, doc)
          yaml_put(doc, "caps", instance.caps&.on?)
        end

        def yaml_hidden_from(instance, value)
          instance.hidden = Properties::Vanish.new(value: value) unless value.nil?
        end

        def yaml_hidden_to(instance, doc)
          yaml_put(doc, "hidden", instance.hidden&.on?)
        end

        # --- Numeric transforms ---

        def yaml_size_from(instance, value)
          instance.size = Properties::FontSize.new(value: value.to_i) if value
        end

        def yaml_size_to(instance, doc)
          yaml_put(doc, "size", instance.size&.value)
        end

        def yaml_character_spacing_from(instance, value)
          instance.character_spacing = Properties::CharacterSpacing.new(value: value.to_i) if value
        end

        def yaml_character_spacing_to(instance, doc)
          yaml_put(doc, "character_spacing", instance.character_spacing&.value)
        end

        # --- String transforms ---

        def yaml_underline_from(instance, value)
          instance.underline = Properties::Underline.new(value: value) if value
        end

        def yaml_underline_to(instance, doc)
          yaml_put(doc, "underline", instance.underline&.value)
        end

        def yaml_color_from(instance, value)
          instance.color = Properties::ColorValue.new(value: value) if value
        end

        def yaml_color_to(instance, doc)
          yaml_put(doc, "color", instance.color&.value)
        end

        def yaml_highlight_from(instance, value)
          instance.highlight = Properties::Highlight.new(value: value) if value
        end

        def yaml_highlight_to(instance, doc)
          yaml_put(doc, "highlight", instance.highlight&.value)
        end

        # --- Font transforms ---

        def yaml_font_from(instance, value)
          instance.fonts ||= Properties::RunFonts.new
          instance.fonts.ascii = value if value
        end

        # "font" and "font_ascii" both name w:rFonts/@w:ascii; write the
        # short spelling once.
        def yaml_font_to(instance, doc)
          yaml_put(doc, "font", instance.fonts&.ascii)
        end

        def yaml_font_ascii_from(instance, value)
          instance.fonts ||= Properties::RunFonts.new
          instance.fonts.ascii = value if value
        end

        def yaml_font_ascii_to(instance, doc)
          yaml_font_to(instance, doc)
        end

        def yaml_font_east_asia_from(instance, value)
          instance.fonts ||= Properties::RunFonts.new
          instance.fonts.east_asia = value if value
        end

        def yaml_font_east_asia_to(instance, doc)
          yaml_put(doc, "font_east_asia", instance.fonts&.east_asia)
        end

        def yaml_font_h_ansi_from(instance, value)
          instance.fonts ||= Properties::RunFonts.new
          instance.fonts.h_ansi = value if value
        end

        def yaml_font_h_ansi_to(instance, doc)
          yaml_put(doc, "font_h_ansi", instance.fonts&.h_ansi)
        end

        def yaml_font_cs_from(instance, value)
          instance.fonts ||= Properties::RunFonts.new
          instance.fonts.cs = value if value
        end

        def yaml_font_cs_to(instance, doc)
          yaml_put(doc, "font_cs", instance.fonts&.cs)
        end

        # --- Effect transforms ---

        def yaml_emboss_from(instance, value)
          instance.emboss = Properties::Emboss.new(value: value) unless value.nil?
        end

        def yaml_emboss_to(instance, doc)
          yaml_put(doc, "emboss", instance.emboss&.on?)
        end

        def yaml_imprint_from(instance, value)
          instance.imprint = Properties::Imprint.new(value: value) unless value.nil?
        end

        def yaml_imprint_to(instance, doc)
          yaml_put(doc, "imprint", instance.imprint&.on?)
        end

        def yaml_shadow_from(instance, value)
          instance.shadow = Properties::Shadow.new(value: value) unless value.nil?
        end

        def yaml_shadow_to(instance, doc)
          yaml_put(doc, "shadow", instance.shadow&.on?)
        end

        # The YAML key "outline" carries w:outlineLvl, not the w:outline
        # toggle. Kept as-is so existing style YAML keeps loading.
        def yaml_outline_from(instance, value)
          instance.outline_level = Properties::OutlineLevel.new(value: value) unless value.nil?
        end

        def yaml_outline_to(instance, doc)
          level = instance.outline_level
          return unless level.is_a?(Properties::OutlineLevel)

          yaml_put(doc, "outline", level.value)
        end

        def yaml_vertical_align_from(instance, value)
          instance.vertical_align = Properties::VerticalAlign.new(value: value) if value
        end

        def yaml_vertical_align_to(instance, doc)
          yaml_put(doc, "vertical_align", instance.vertical_align&.value)
        end
      end
    end
  end
end
