# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Run (character) formatting properties
    #
    # Represents w:rPr element containing character-level formatting.
    # Used in StyleSets and run elements.
    class RunProperties < Lutaml::Model::Serializable
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
      attribute :shadow, Properties::Shadow, default: nil
      attribute :emboss, Properties::Emboss, default: nil
      attribute :imprint, Properties::Imprint, default: nil
      attribute :outline, Properties::Outline, default: nil
      attribute :outline_level, Properties::OutlineLevel, default: nil

      # YAML mappings for flat YAML structure (StyleSet compatibility)
      yaml do
        map 'bold', with: { from: :yaml_bold_from, to: :yaml_bold_to }
        map 'italic', with: { from: :yaml_italic_from, to: :yaml_italic_to }
        map 'strike', with: { from: :yaml_strike_from, to: :yaml_strike_to }
        map 'double_strike', with: { from: :yaml_double_strike_from, to: :yaml_double_strike_to }
        map 'small_caps', with: { from: :yaml_small_caps_from, to: :yaml_small_caps_to }
        map 'caps', with: { from: :yaml_caps_from, to: :yaml_caps_to }
        map 'all_caps', with: { from: :yaml_caps_from, to: :yaml_caps_to }  # Alias
        map 'hidden', with: { from: :yaml_hidden_from, to: :yaml_hidden_to }
        map 'size', with: { from: :yaml_size_from, to: :yaml_size_to }
        map 'spacing', with: { from: :yaml_character_spacing_from, to: :yaml_character_spacing_to }
        map 'character_spacing', with: { from: :yaml_character_spacing_from, to: :yaml_character_spacing_to }
        map 'underline', with: { from: :yaml_underline_from, to: :yaml_underline_to }
        map 'color', with: { from: :yaml_color_from, to: :yaml_color_to }
        map 'highlight', with: { from: :yaml_highlight_from, to: :yaml_highlight_to }
        map 'font', with: { from: :yaml_font_from, to: :yaml_font_to }
        map 'font_ascii', with: { from: :yaml_font_ascii_from, to: :yaml_font_ascii_to }
        map 'font_east_asia', with: { from: :yaml_font_east_asia_from, to: :yaml_font_east_asia_to }
        map 'font_h_ansi', with: { from: :yaml_font_h_ansi_from, to: :yaml_font_h_ansi_to }
        map 'font_cs', with: { from: :yaml_font_cs_from, to: :yaml_font_cs_to }
        map 'emboss', with: { from: :yaml_emboss_from, to: :yaml_emboss_to }
        map 'imprint', with: { from: :yaml_imprint_from, to: :yaml_imprint_to }
        map 'shadow', with: { from: :yaml_shadow_from, to: :yaml_shadow_to }
        map 'outline', with: { from: :yaml_outline_from, to: :yaml_outline_to }
        map 'vertical_align', with: { from: :yaml_vertical_align_from, to: :yaml_vertical_align_to }
      end

      # YAML transform methods
      def yaml_bold_from(instance, value)
        instance.bold = Properties::Bold.new(value: value) unless value.nil?
      end

      def yaml_bold_to(instance, doc)
        bold&.value
      end

      def yaml_italic_from(instance, value)
        instance.italic = Properties::Italic.new(value: value) unless value.nil?
      end

      def yaml_italic_to(instance, doc)
        italic&.value
      end

      def yaml_strike_from(instance, value)
        instance.strike = Properties::Strike.new(value: value) unless value.nil?
      end

      def yaml_strike_to(instance, doc)
        strike&.value
      end

      def yaml_double_strike_from(instance, value)
        instance.double_strike = Properties::DoubleStrike.new(value: value) unless value.nil?
      end

      def yaml_double_strike_to(instance, doc)
        double_strike&.value
      end

      def yaml_small_caps_from(instance, value)
        instance.small_caps = Properties::SmallCaps.new(value: value) unless value.nil?
      end

      def yaml_small_caps_to(instance, doc)
        small_caps&.value
      end

      def yaml_caps_from(instance, value)
        instance.caps = Properties::Caps.new(value: value) unless value.nil?
      end

      def yaml_caps_to(instance, doc)
        caps&.value
      end

      def yaml_hidden_from(instance, value)
        instance.hidden = Properties::Vanish.new(value: value) unless value.nil?
      end

      def yaml_hidden_to(instance, doc)
        hidden&.value
      end

      def yaml_size_from(instance, value)
        instance.size = Properties::FontSize.new(value: value.to_i) if value
      end

      def yaml_size_to(instance, doc)
        size&.value
      end

      def yaml_character_spacing_from(instance, value)
        instance.character_spacing = Properties::CharacterSpacing.new(value: value.to_i) if value
      end

      def yaml_character_spacing_to(instance, doc)
        character_spacing&.value
      end

      def yaml_underline_from(instance, value)
        instance.underline = Properties::Underline.new(value: value) if value
      end

      def yaml_underline_to(instance, doc)
        underline&.value
      end

      def yaml_color_from(instance, value)
        instance.color = Properties::ColorValue.new(value: value) if value
      end

      def yaml_color_to(instance, doc)
        color&.value
      end

      def yaml_highlight_from(instance, value)
        instance.highlight = Properties::Highlight.new(value: value) if value
      end

      def yaml_highlight_to(instance, doc)
        highlight&.value
      end

      def yaml_font_from(instance, value)
        instance.fonts ||= Properties::RunFonts.new
        instance.fonts.ascii = value if value
      end

      def yaml_font_to(instance, doc)
        fonts&.ascii
      end

      def yaml_font_ascii_from(instance, value)
        instance.fonts ||= Properties::RunFonts.new
        instance.fonts.ascii = value if value
      end

      def yaml_font_ascii_to(instance, doc)
        fonts&.ascii
      end

      def yaml_font_east_asia_from(instance, value)
        instance.fonts ||= Properties::RunFonts.new
        instance.fonts.east_asia = value if value
      end

      def yaml_font_east_asia_to(instance, doc)
        fonts&.east_asia
      end

      def yaml_font_h_ansi_from(instance, value)
        instance.fonts ||= Properties::RunFonts.new
        instance.fonts.h_ansi = value if value
      end

      def yaml_font_h_ansi_to(instance, doc)
        fonts&.h_ansi
      end

      def yaml_font_cs_from(instance, value)
        instance.fonts ||= Properties::RunFonts.new
        instance.fonts.cs = value if value
      end

      def yaml_font_cs_to(instance, doc)
        fonts&.cs
      end

      def yaml_emboss_from(instance, value)
        instance.emboss = Properties::Emboss.new(value: value) unless value.nil?
      end

      def yaml_emboss_to(instance, doc)
        emboss&.value
      end

      def yaml_imprint_from(instance, value)
        instance.imprint = Properties::Imprint.new(value: value) unless value.nil?
      end

      def yaml_imprint_to(instance, doc)
        imprint&.value
      end

      def yaml_shadow_from(instance, value)
        instance.shadow = Properties::Shadow.new(value: value) unless value.nil?
      end

      def yaml_shadow_to(instance, doc)
        shadow&.value
      end

      def yaml_outline_from(instance, value)
        instance.outline_level = Properties::OutlineLevel.new(value: value) unless value.nil?
      end

      def yaml_outline_to(instance, doc)
        outline_level&.value
      end

      def yaml_vertical_align_from(instance, value)
        instance.vertical_align = Properties::VerticalAlign.new(value: value) if value
      end

      def yaml_vertical_align_to(instance, doc)
        vertical_align&.value
      end

      # XML mappings come AFTER attributes
      xml do
        element 'rPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        # Style reference (wrapper object)
        map_element 'rStyle', to: :style, render_nil: false

        # Fonts (complex object)
        map_element 'rFonts', to: :fonts, render_nil: false

        # Font sizes (wrapper objects)
        map_element 'sz', to: :size, render_nil: false
        map_element 'szCs', to: :size_cs, render_nil: false

        # Boolean formatting (wrapper objects)
        map_element 'b', to: :bold, render_nil: false
        map_element 'bCs', to: :bold_cs, render_nil: false
        map_element 'i', to: :italic, render_nil: false
        map_element 'iCs', to: :italic_cs, render_nil: false
        map_element 'strike', to: :strike, render_nil: false
        map_element 'dstrike', to: :double_strike, render_nil: false
        map_element 'smallCaps', to: :small_caps, render_nil: false
        map_element 'caps', to: :caps, render_nil: false
        map_element 'vanish', to: :hidden, render_nil: false
        map_element 'noProof', to: :no_proof, render_nil: false

        # Color (wrapper object)
        map_element 'color', to: :color, render_nil: false

        # Underline (wrapper object)
        map_element 'u', to: :underline, render_nil: false

        # Highlight (wrapper object)
        map_element 'highlight', to: :highlight, render_nil: false

        # Vertical alignment (wrapper object)
        map_element 'vertAlign', to: :vertical_align, render_nil: false

        # Position (wrapper object)
        map_element 'position', to: :position, render_nil: false

        # Character spacing (wrapper object)
        map_element 'spacing', to: :character_spacing, render_nil: false

        # Kerning (wrapper object)
        map_element 'kern', to: :kerning, render_nil: false

        # Width scale (wrapper object)
        map_element 'w', to: :width_scale, render_nil: false

        # Emphasis mark (wrapper object)
        map_element 'em', to: :emphasis_mark, render_nil: false

        # Shading (complex object)
        map_element 'shd', to: :shading, render_nil: false

        # Language (complex object)
        map_element 'lang', to: :language, render_nil: false

        # Text effects (complex objects - basic support)
        map_element 'textFill', to: :text_fill, render_nil: false
        map_element 'textOutline', to: :text_outline, render_nil: false

        # Additional boolean formatting
        map_element 'shadow', to: :shadow, render_nil: false
        map_element 'emboss', to: :emboss, render_nil: false
        map_element 'imprint', to: :imprint, render_nil: false
        map_element 'outline', to: :outline, render_nil: false
      end

      # Helper methods for boolean values (handle both wrapper and primitive)
      def bold?
        val = bold
        return false if val.nil?

        val = val.value if val.is_a?(Uniword::Properties::BooleanElement)
        val == true
      end

      def italic?
        val = italic
        return false if val.nil?

        val = val.value if val.is_a?(Uniword::Properties::BooleanElement)
        val == true
      end

      def strike?
        val = strike
        return false if val.nil?

        val = val.value if val.is_a?(Uniword::Properties::BooleanElement)
        val == true
      end

      # Get all_caps - returns boolean
      def all_caps
        val = @all_caps || caps
        return false if val.nil?

        val = val.value if val.is_a?(Uniword::Properties::BooleanElement)
        val == true
      end

      # Set all_caps
      def all_caps=(value)
        @all_caps = value
        self.caps = value.is_a?(Properties::Caps) ? value : Properties::Caps.new(value: value)
        value
      end

      # Get all_caps? (alias for caps?)
      def all_caps?
        caps?
      end

      # Get caps? predicate
      def caps?
        val = caps
        return false if val.nil?

        val = val.value if val.is_a?(Uniword::Properties::BooleanElement)
        val == true
      end

      # Font convenience getters - delegate to fonts wrapper
      def font
        fonts&.ascii
      end

      # Set font name on ASCII slot
      def font=(value)
        self.fonts ||= Properties::RunFonts.new
        fonts.ascii = value
      end

      def font_ascii
        fonts&.ascii
      end

      def font_east_asia
        fonts&.east_asia
      end

      def font_h_ansi
        fonts&.h_ansi
      end

      def font_cs
        fonts&.cs
      end

      # Language convenience getters - delegate to language wrapper
      def language_val
        language&.val
      end

      def language_east_asia
        language&.east_asia
      end

      def language_bidi
        language&.bidi
      end

      # Shading convenience getters - delegate to shading wrapper
      def shading_fill
        shading&.fill
      end

      def shading_type
        shading&.pattern
      end

      # Convenience predicate methods for RunProperties
      def small_caps?
        val = small_caps
        return false if val.nil?

        val = val.value if val.is_a?(Properties::SmallCaps)
        val == true
      end

      def shadow?
        val = shadow
        return false if val.nil?

        val = val.value if val.is_a?(Properties::Shadow)
        val == true
      end

      def imprint?
        val = imprint
        return false if val.nil?

        val = val.value if val.is_a?(Properties::Imprint)
        val == true
      end

      def emboss?
        val = emboss
        return false if val.nil?

        val = val.value if val.is_a?(Properties::Emboss)
        val == true
      end

      def hidden?
        val = hidden
        return false if val.nil?

        val = val.value if val.is_a?(Properties::Vanish)
        val == true
      end

      def outline?
        val = outline
        return false if val.nil?

        val = val.val if val.is_a?(Properties::Outline)
        val != 'false'
      end

      def shading_color
        shading&.fill
      end

      def shading_color=(value)
        self.shading ||= Properties::Shading.new
        shading.fill = value
        self
      end

      def page_break=(_value)
        self
      end

      # Get text expansion (alias for width_scale)
      #
      # @return [Properties::WidthScale, nil] Width scale wrapper object
      def text_expansion
        width_scale
      end

      # Set text expansion
      #
      # @param value [Integer, Properties::WidthScale] Width scale value
      # @return [self] For method chaining
      def text_expansion=(value)
        self.width_scale = if value.is_a?(Properties::WidthScale)
                             value
                           else
                             Properties::WidthScale.new(value: value)
                           end
        self
      end

      # Initialize with defaults and handle primitive-to-wrapper conversion
      def initialize(attrs = {})
        # Extract flat convenience keys before super (lutaml-model ignores
        # unknown keys). These are converted to proper wrapper objects below.
        font_val = attrs.delete(:font) || attrs.delete('font')
        font_ascii_val = attrs.delete(:font_ascii) || attrs.delete('font_ascii')
        font_ea_val = attrs.delete(:font_east_asia) || attrs.delete('font_east_asia')
        font_ha_val = attrs.delete(:font_h_ansi) || attrs.delete('font_h_ansi')
        font_cs_val = attrs.delete(:font_cs) || attrs.delete('font_cs')
        lang_val = attrs.delete(:language_val) || attrs.delete('language_val')
        lang_ea = attrs.delete(:language_east_asia) || attrs.delete('language_east_asia')
        lang_bidi = attrs.delete(:language_bidi) || attrs.delete('language_bidi')
        # Also intercept language: 'en-US' (lutaml-model stores raw string
        # when a primitive is passed for a typed attribute via constructor).
        # Only extract if it's a String; leave Properties::Language objects
        # for lutaml-model to handle normally.
        raw_language = attrs[:language] || attrs['language']
        if raw_language.is_a?(String)
          attrs.delete(:language)
          attrs.delete('language')
        else
          raw_language = nil
        end
        shading_fill_val = attrs.delete(:shading_fill) || attrs.delete('shading_fill')
        shading_type_val = attrs.delete(:shading_type) || attrs.delete('shading_type')

        super

        # Convert primitive values to wrapper objects (Pattern 0: run after super)
        # This handles cases like RunProperties.new(bold: true) where primitives
        # are passed instead of wrapper objects
        convert_primitive_attributes!

        # Map removed flat font attributes to fonts wrapper.
        # font_ascii takes precedence over font for the ASCII slot.
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
        if font_cs_val
          self.fonts ||= Properties::RunFonts.new
          fonts.cs = font_cs_val
        end

        # Map removed flat language attributes to language wrapper.
        if lang_val || lang_ea || lang_bidi || raw_language
          self.language = Properties::Language.new
          language.val = lang_val || raw_language if lang_val || raw_language
          language.east_asia = lang_ea if lang_ea
          language.bidi = lang_bidi if lang_bidi
        end

        # Map removed flat shading attributes to shading wrapper
        if shading_fill_val || shading_type_val
          self.shading ||= Properties::Shading.new
          shading.fill = shading_fill_val if shading_fill_val
          shading.pattern = shading_type_val if shading_type_val
        end
      end

      # Convert primitive attribute values to proper wrapper objects
      # Called after super() to handle cases where primitives were passed
      # instead of the expected Serializable wrapper types
      def convert_primitive_attributes!
        # Boolean formatting properties
        if @bold && !@bold.is_a?(Properties::Bold)
          @bold = Properties::Bold.new(value: @bold)
        end
        if @bold_cs && !@bold_cs.is_a?(Properties::BoldCs)
          @bold_cs = Properties::BoldCs.new(value: @bold_cs)
        end
        if @italic && !@italic.is_a?(Properties::Italic)
          @italic = Properties::Italic.new(value: @italic)
        end
        if @italic_cs && !@italic_cs.is_a?(Properties::ItalicCs)
          @italic_cs = Properties::ItalicCs.new(value: @italic_cs)
        end
        if @strike && !@strike.is_a?(Properties::Strike)
          @strike = Properties::Strike.new(value: @strike)
        end
        if @double_strike && !@double_strike.is_a?(Properties::DoubleStrike)
          @double_strike = Properties::DoubleStrike.new(value: @double_strike)
        end
        if @small_caps && !@small_caps.is_a?(Properties::SmallCaps)
          @small_caps = Properties::SmallCaps.new(value: @small_caps)
        end
        if @caps && !@caps.is_a?(Properties::Caps)
          @caps = Properties::Caps.new(value: @caps)
        end
        if @hidden && !@hidden.is_a?(Properties::Vanish)
          @hidden = Properties::Vanish.new(value: @hidden)
        end

        # Style - convert string to RunStyleReference wrapper
        if @style.is_a?(String)
          @style = Properties::RunStyleReference.new(value: @style)
        end

        # Font size (half-points)
        if @size && !@size.is_a?(Properties::FontSize)
          val = @size.is_a?(Numeric) ? @size : @size.to_i
          @size = Properties::FontSize.new(value: val)
        end
        if @size_cs && !@size_cs.is_a?(Properties::FontSize)
          val = @size_cs.is_a?(Numeric) ? @size_cs : @size_cs.to_i
          @size_cs = Properties::FontSize.new(value: val)
        end

        # Color
        if @color && !@color.is_a?(Properties::ColorValue)
          @color = Properties::ColorValue.new(value: @color.to_s)
        end

        # Underline
        if @underline && !@underline.is_a?(Properties::Underline)
          @underline = if @underline == true || @underline == 'single'
                         Properties::Underline.new(value: 'single')
                       elsif @underline.is_a?(String)
                         Properties::Underline.new(value: @underline)
                       else
                         Properties::Underline.new(value: @underline.to_s)
                       end
        end

        # Highlight
        if @highlight && !@highlight.is_a?(Properties::Highlight)
          @highlight = Properties::Highlight.new(value: @highlight.to_s)
        end

        # Vertical alignment
        if @vertical_align && !@vertical_align.is_a?(Properties::VerticalAlign)
          @vertical_align = Properties::VerticalAlign.new(value: @vertical_align.to_s)
        end

        # Position
        if @position && !@position.is_a?(Properties::Position)
          @position = Properties::Position.new(value: @position)
        end

        # Character spacing
        if @character_spacing && !@character_spacing.is_a?(Properties::CharacterSpacing)
          @character_spacing = Properties::CharacterSpacing.new(value: @character_spacing)
        end

        # Kerning
        if @kerning && !@kerning.is_a?(Properties::Kerning)
          @kerning = Properties::Kerning.new(value: @kerning)
        end

        # Width scale
        if @width_scale && !@width_scale.is_a?(Properties::WidthScale)
          @width_scale = Properties::WidthScale.new(value: @width_scale)
        end

        # Emphasis mark
        if @emphasis_mark && !@emphasis_mark.is_a?(Properties::EmphasisMark)
          @emphasis_mark = Properties::EmphasisMark.new(value: @emphasis_mark.to_s)
        end

        # Text fill
        if @text_fill && !@text_fill.is_a?(Properties::TextFill)
          @text_fill = Properties::TextFill.new
        end

        # Text outline
        if @text_outline && !@text_outline.is_a?(Properties::TextOutline)
          @text_outline = Properties::TextOutline.new
        end

      end
    end
  end
end
