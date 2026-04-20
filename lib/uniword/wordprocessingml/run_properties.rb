# frozen_string_literal: true

require "lutaml/model"

require_relative "run_properties/yaml_transforms"
require_relative "run_properties/predicates"
require_relative "run_properties/accessors"
require_relative "run_properties/conversion"

module Uniword
  module Wordprocessingml
    # Run (character) formatting properties
    #
    # Represents w:rPr element containing character-level formatting.
    # Used in StyleSets and run elements.
    class RunProperties < Lutaml::Model::Serializable
      include YamlTransforms
      include Predicates
      include Accessors
      prepend Conversion

      # Pattern 0: ATTRIBUTES FIRST, then XML mappings

      # Simple element wrapper objects (default: nil so unset properties are nil)
      attribute :style, Properties::RunStyleReference, default: nil
      attribute :size, Properties::FontSize, default: nil
      attribute :size_cs, Properties::FontSize, default: nil
      attribute :color, Properties::ColorValue, default: nil
      attribute :underline, Properties::Underline, default: nil
      attribute :highlight, Properties::Highlight, default: nil
      attribute :vertical_align, Properties::VerticalAlign, default: nil
      attribute :position, Properties::Position, default: nil
      attribute :character_spacing, Properties::CharacterSpacing, default: nil
      attribute :kerning, Properties::Kerning, default: nil
      attribute :width_scale, Properties::WidthScale, default: nil
      attribute :emphasis_mark, Properties::EmphasisMark, default: nil

      # Complex fonts object
      attribute :fonts, Properties::RunFonts, default: nil

      # Complex shading object
      attribute :shading, Properties::Shading, default: nil

      # Complex language object
      attribute :language, Properties::Language, default: nil

      # Complex text effects objects
      attribute :text_fill, Properties::TextFill, default: nil
      attribute :text_outline, Properties::TextOutline, default: nil

      # Boolean formatting wrapper objects (default: nil so unset properties are nil)
      attribute :bold, Properties::Bold, default: nil
      attribute :bold_cs, Properties::BoldCs, default: nil
      attribute :italic, Properties::Italic, default: nil
      attribute :italic_cs, Properties::ItalicCs, default: nil
      attribute :strike, Properties::Strike, default: nil
      attribute :double_strike, Properties::DoubleStrike, default: nil
      attribute :small_caps, Properties::SmallCaps, default: nil
      attribute :caps, Properties::Caps, default: nil
      attribute :hidden, Properties::Vanish, default: nil
      attribute :no_proof, Properties::NoProof, default: nil
      attribute :web_hidden, Properties::WebHidden, default: nil
      attribute :shadow, Properties::Shadow, default: nil
      attribute :emboss, Properties::Emboss, default: nil
      attribute :imprint, Properties::Imprint, default: nil
      attribute :outline, Properties::Outline, default: nil
      attribute :outline_level, Properties::OutlineLevel, default: nil

      # W14 namespace elements
      attribute :ligatures, Uniword::Wordprocessingml2010::Ligatures, default: nil

      # YAML mappings for flat YAML structure (StyleSet compatibility)
      yaml do
        map "bold", with: { from: :yaml_bold_from, to: :yaml_bold_to }
        map "italic", with: { from: :yaml_italic_from, to: :yaml_italic_to }
        map "strike", with: { from: :yaml_strike_from, to: :yaml_strike_to }
        map "double_strike", with: { from: :yaml_double_strike_from, to: :yaml_double_strike_to }
        map "small_caps", with: { from: :yaml_small_caps_from, to: :yaml_small_caps_to }
        map "caps", with: { from: :yaml_caps_from, to: :yaml_caps_to }
        map "all_caps", with: { from: :yaml_caps_from, to: :yaml_caps_to } # Alias
        map "hidden", with: { from: :yaml_hidden_from, to: :yaml_hidden_to }
        map "size", with: { from: :yaml_size_from, to: :yaml_size_to }
        map "spacing", with: { from: :yaml_character_spacing_from, to: :yaml_character_spacing_to }
        map "character_spacing",
            with: { from: :yaml_character_spacing_from, to: :yaml_character_spacing_to }
        map "underline", with: { from: :yaml_underline_from, to: :yaml_underline_to }
        map "color", with: { from: :yaml_color_from, to: :yaml_color_to }
        map "highlight", with: { from: :yaml_highlight_from, to: :yaml_highlight_to }
        map "font", with: { from: :yaml_font_from, to: :yaml_font_to }
        map "font_ascii", with: { from: :yaml_font_ascii_from, to: :yaml_font_ascii_to }
        map "font_east_asia", with: { from: :yaml_font_east_asia_from, to: :yaml_font_east_asia_to }
        map "font_h_ansi", with: { from: :yaml_font_h_ansi_from, to: :yaml_font_h_ansi_to }
        map "font_cs", with: { from: :yaml_font_cs_from, to: :yaml_font_cs_to }
        map "emboss", with: { from: :yaml_emboss_from, to: :yaml_emboss_to }
        map "imprint", with: { from: :yaml_imprint_from, to: :yaml_imprint_to }
        map "shadow", with: { from: :yaml_shadow_from, to: :yaml_shadow_to }
        map "outline", with: { from: :yaml_outline_from, to: :yaml_outline_to }
        map "vertical_align", with: { from: :yaml_vertical_align_from, to: :yaml_vertical_align_to }
      end

      # XML mappings come AFTER attributes
      xml do
        element "rPr"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        # Style reference (wrapper object)
        map_element "rStyle", to: :style, render_nil: false

        # Fonts (complex object)
        map_element "rFonts", to: :fonts, render_nil: false

        # Font sizes (wrapper objects)
        map_element "sz", to: :size, render_nil: false
        map_element "szCs", to: :size_cs, render_nil: false

        # Boolean formatting (wrapper objects)
        map_element "b", to: :bold, render_nil: false
        map_element "bCs", to: :bold_cs, render_nil: false
        map_element "i", to: :italic, render_nil: false
        map_element "iCs", to: :italic_cs, render_nil: false
        map_element "strike", to: :strike, render_nil: false
        map_element "dstrike", to: :double_strike, render_nil: false
        map_element "smallCaps", to: :small_caps, render_nil: false
        map_element "caps", to: :caps, render_nil: false
        map_element "vanish", to: :hidden, render_nil: false
        map_element "noProof", to: :no_proof, render_nil: false
        map_element "webHidden", to: :web_hidden, render_nil: false

        # Color (wrapper object)
        map_element "color", to: :color, render_nil: false

        # Underline (wrapper object)
        map_element "u", to: :underline, render_nil: false

        # Highlight (wrapper object)
        map_element "highlight", to: :highlight, render_nil: false

        # Vertical alignment (wrapper object)
        map_element "vertAlign", to: :vertical_align, render_nil: false

        # Position (wrapper object)
        map_element "position", to: :position, render_nil: false

        # Character spacing (wrapper object)
        map_element "spacing", to: :character_spacing, render_nil: false

        # Kerning (wrapper object)
        map_element "kern", to: :kerning, render_nil: false

        # Width scale (wrapper object)
        map_element "w", to: :width_scale, render_nil: false

        # Emphasis mark (wrapper object)
        map_element "em", to: :emphasis_mark, render_nil: false

        # Shading (complex object)
        map_element "shd", to: :shading, render_nil: false

        # Language (complex object)
        map_element "lang", to: :language, render_nil: false

        # Text effects (complex objects - basic support)
        map_element "textFill", to: :text_fill, render_nil: false
        map_element "textOutline", to: :text_outline, render_nil: false

        # Additional boolean formatting
        map_element "shadow", to: :shadow, render_nil: false
        map_element "emboss", to: :emboss, render_nil: false
        map_element "imprint", to: :imprint, render_nil: false
        map_element "outline", to: :outline, render_nil: false

        # W14 namespace elements
        map_element "ligatures", to: :ligatures, render_nil: false
      end
    end
  end
end
