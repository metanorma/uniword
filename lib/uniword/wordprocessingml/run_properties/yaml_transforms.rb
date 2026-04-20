# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    class RunProperties < Lutaml::Model::Serializable
      # YAML serialization transforms for RunProperties.
      #
      # Handles bidirectional conversion between flat YAML keys
      # (bold, italic, size, etc.) and the wrapper objects used
      # internally by the OOXML model.
      module YamlTransforms
        # --- Boolean transforms ---

        def yaml_bold_from(instance, value)
          instance.bold = Properties::Bold.new(value: value) unless value.nil?
        end

        def yaml_bold_to(_instance, _doc)
          bold&.value
        end

        def yaml_italic_from(instance, value)
          instance.italic = Properties::Italic.new(value: value) unless value.nil?
        end

        def yaml_italic_to(_instance, _doc)
          italic&.value
        end

        def yaml_strike_from(instance, value)
          instance.strike = Properties::Strike.new(value: value) unless value.nil?
        end

        def yaml_strike_to(_instance, _doc)
          strike&.value
        end

        def yaml_double_strike_from(instance, value)
          instance.double_strike = Properties::DoubleStrike.new(value: value) unless value.nil?
        end

        def yaml_double_strike_to(_instance, _doc)
          double_strike&.value
        end

        def yaml_small_caps_from(instance, value)
          instance.small_caps = Properties::SmallCaps.new(value: value) unless value.nil?
        end

        def yaml_small_caps_to(_instance, _doc)
          small_caps&.value
        end

        def yaml_caps_from(instance, value)
          instance.caps = Properties::Caps.new(value: value) unless value.nil?
        end

        def yaml_caps_to(_instance, _doc)
          caps&.value
        end

        def yaml_hidden_from(instance, value)
          instance.hidden = Properties::Vanish.new(value: value) unless value.nil?
        end

        def yaml_hidden_to(_instance, _doc)
          hidden&.value
        end

        # --- Numeric transforms ---

        def yaml_size_from(instance, value)
          instance.size = Properties::FontSize.new(value: value.to_i) if value
        end

        def yaml_size_to(_instance, _doc)
          size&.value
        end

        def yaml_character_spacing_from(instance, value)
          instance.character_spacing = Properties::CharacterSpacing.new(value: value.to_i) if value
        end

        def yaml_character_spacing_to(_instance, _doc)
          character_spacing&.value
        end

        # --- String transforms ---

        def yaml_underline_from(instance, value)
          instance.underline = Properties::Underline.new(value: value) if value
        end

        def yaml_underline_to(_instance, _doc)
          underline&.value
        end

        def yaml_color_from(instance, value)
          instance.color = Properties::ColorValue.new(value: value) if value
        end

        def yaml_color_to(_instance, _doc)
          color&.value
        end

        def yaml_highlight_from(instance, value)
          instance.highlight = Properties::Highlight.new(value: value) if value
        end

        def yaml_highlight_to(_instance, _doc)
          highlight&.value
        end

        # --- Font transforms ---

        def yaml_font_from(instance, value)
          instance.fonts ||= Properties::RunFonts.new
          instance.fonts.ascii = value if value
        end

        def yaml_font_to(_instance, _doc)
          fonts&.ascii
        end

        def yaml_font_ascii_from(instance, value)
          instance.fonts ||= Properties::RunFonts.new
          instance.fonts.ascii = value if value
        end

        def yaml_font_ascii_to(_instance, _doc)
          fonts&.ascii
        end

        def yaml_font_east_asia_from(instance, value)
          instance.fonts ||= Properties::RunFonts.new
          instance.fonts.east_asia = value if value
        end

        def yaml_font_east_asia_to(_instance, _doc)
          fonts&.east_asia
        end

        def yaml_font_h_ansi_from(instance, value)
          instance.fonts ||= Properties::RunFonts.new
          instance.fonts.h_ansi = value if value
        end

        def yaml_font_h_ansi_to(_instance, _doc)
          fonts&.h_ansi
        end

        def yaml_font_cs_from(instance, value)
          instance.fonts ||= Properties::RunFonts.new
          instance.fonts.cs = value if value
        end

        def yaml_font_cs_to(_instance, _doc)
          fonts&.cs
        end

        # --- Effect transforms ---

        def yaml_emboss_from(instance, value)
          instance.emboss = Properties::Emboss.new(value: value) unless value.nil?
        end

        def yaml_emboss_to(_instance, _doc)
          emboss&.value
        end

        def yaml_imprint_from(instance, value)
          instance.imprint = Properties::Imprint.new(value: value) unless value.nil?
        end

        def yaml_imprint_to(_instance, _doc)
          imprint&.value
        end

        def yaml_shadow_from(instance, value)
          instance.shadow = Properties::Shadow.new(value: value) unless value.nil?
        end

        def yaml_shadow_to(_instance, _doc)
          shadow&.value
        end

        def yaml_outline_from(instance, value)
          instance.outline_level = Properties::OutlineLevel.new(value: value) unless value.nil?
        end

        def yaml_outline_to(_instance, _doc)
          outline_level&.value
        end

        def yaml_vertical_align_from(instance, value)
          instance.vertical_align = Properties::VerticalAlign.new(value: value) if value
        end

        def yaml_vertical_align_to(_instance, _doc)
          vertical_align&.value
        end
      end
    end
  end
end
