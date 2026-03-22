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
      attribute :style, Properties::StyleReference, default: nil
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
      attribute :_shadow_val, Properties::Shadow, default: nil
      attribute :_emboss_val, Properties::Emboss, default: nil
      attribute :_imprint_val, Properties::Imprint, default: nil
      attribute :outline_level, Properties::OutlineLevel, default: nil

      # Flat attributes (kept as aliases for compatibility)
      attribute :spacing, :integer          # Flat attribute (deprecated)
      attribute :kern, :integer             # Flat attribute (deprecated)
      attribute :w_scale, :integer          # Flat attribute (deprecated)
      attribute :em, :string                # Flat attribute (deprecated)

      # Flat language attributes (deprecated, kept for compatibility)
      attribute :language_val, :string      # Language code (e.g., "en-US")
      attribute :language_bidi, :string     # BiDi language
      attribute :language_east_asia, :string # East Asian language

      # Flat shading (deprecated, kept for compatibility)
      attribute :shading_fill, :string # Background fill color (flat)
      attribute :shading_type, :string # Shading pattern (flat)

      # Flat font attributes (convenience for API access)
      attribute :font, :string           # Primary font (maps to ASCII)
      attribute :font_ascii, :string     # ASCII font
      attribute :font_east_asia, :string # East Asian font
      attribute :font_h_ansi, :string    # High ANSI font
      attribute :font_cs, :string        # Complex script font

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
        map 'spacing', to: :spacing
        map 'character_spacing', with: { from: :yaml_character_spacing_from, to: :yaml_character_spacing_to }
        map 'underline', with: { from: :yaml_underline_from, to: :yaml_underline_to }
        map 'color', with: { from: :yaml_color_from, to: :yaml_color_to }
        map 'highlight', with: { from: :yaml_highlight_from, to: :yaml_highlight_to }
        map 'font', to: :font
        map 'font_ascii', to: :font_ascii
        map 'font_east_asia', to: :font_east_asia
        map 'font_h_ansi', to: :font_h_ansi
        map 'font_cs', to: :font_cs
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
        map_element 'shadow', to: :_shadow_val, render_nil: false
        map_element 'emboss', to: :_emboss_val, render_nil: false
        map_element 'imprint', to: :_imprint_val, render_nil: false
        map_element 'outline', to: :outline_level, render_nil: false
      end

      # Helper methods for boolean values (handle both wrapper and primitive)
      def bold?
        val = bold
        return false if val.nil?

        val = val.value if val.respond_to?(:value)
        val == true
      end

      def italic?
        val = italic
        return false if val.nil?

        val = val.value if val.respond_to?(:value)
        val == true
      end

      def strike?
        val = strike
        return false if val.nil?

        val = val.value if val.respond_to?(:value)
        val == true
      end

      # Get all_caps - returns boolean
      def all_caps
        val = @all_caps || caps
        return false if val.nil?

        val = val.value if val.respond_to?(:value)
        val == true
      end

      # Set all_caps
      def all_caps=(value)
        @all_caps = value
        instance.caps = value.is_a?(Properties::Caps) ? value : Properties::Caps.new(value: value)
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

        val = val.value if val.respond_to?(:value)
        val == true
      end

      # Font convenience method - get ASCII font name
      # Returns flat attribute if set, otherwise falls back to fonts object
      def font
        @font || fonts&.ascii
      end

      # Set font name on all font types
      def font=(value)
        @font = value
        self.fonts ||= Properties::RunFonts.new
        fonts.ascii = value
        value
      end

      # Get East Asian font
      def font_east_asia
        @font_east_asia || fonts&.east_asia
      end

      # Set East Asian font
      def font_east_asia=(value)
        @font_east_asia = value
        self.fonts ||= Properties::RunFonts.new
        fonts.east_asia = value
        value
      end

      # Get High ANSI font
      def font_h_ansi
        @font_h_ansi || fonts&.h_ansi
      end

      # Set High ANSI font
      def font_h_ansi=(value)
        @font_h_ansi = value
        self.fonts ||= Properties::RunFonts.new
        fonts.h_ansi = value
        value
      end

      # Get Complex Script font
      def font_cs
        @font_cs || fonts&.cs
      end

      # Set Complex Script font
      def font_cs=(value)
        @font_cs = value
        self.fonts ||= Properties::RunFonts.new
        fonts.cs = value
        value
      end

      # Get ASCII font (alias for font)
      def font_ascii
        @font_ascii || fonts&.ascii
      end

      # Set ASCII font (alias for font)
      def font_ascii=(value)
        @font_ascii = value
        self.fonts ||= Properties::RunFonts.new
        fonts.ascii = value
        value
      end

      # Convenience methods for RunProperties
      def small_caps?
        val = small_caps
        return false if val.nil?

        val = val.value if val.respond_to?(:value)
        val == true
      end

      def shadow?
        val = _shadow_val
        return false if val.nil?

        val = val.value if val.respond_to?(:value)
        val == true
      end

      # Get shadow value (boolean)
      def shadow
        shadow?
      end

      # Set shadow value
      def shadow=(value)
        @_shadow_val = if value.is_a?(Properties::Shadow)
                             value
                           else
                             Properties::Shadow.new(value: value)
                           end
        @using_default ||= {}
        @using_default[:_shadow_val] = false
      end

      def imprint?
        val = _imprint_val
        return false if val.nil?

        val = val.value if val.respond_to?(:value)
        val == true
      end

      # Get imprint value (boolean)
      def imprint
        imprint?
      end

      # Set imprint value
      def imprint=(value)
        @_imprint_val = if value.is_a?(Properties::Imprint)
                               value
                             else
                               Properties::Imprint.new(value: value)
                             end
        @using_default ||= {}
        @using_default[:_imprint_val] = false
      end

      def emboss?
        val = _emboss_val
        return false if val.nil?

        val = val.value if val.respond_to?(:value)
        val == true
      end

      # Get emboss value (boolean)
      def emboss
        emboss?
      end

      # Set emboss value
      def emboss=(value)
        @_emboss_val = if value.is_a?(Properties::Emboss)
                              value
                            else
                              Properties::Emboss.new(value: value)
                            end
        @using_default ||= {}
        @using_default[:_emboss_val] = false
      end

      def hidden?
        val = hidden
        return false if val.nil?

        val = val.value if val.respond_to?(:value)
        val == true
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

      # Get outline (character outline effect) - returns boolean for spec compatibility
      def outline
        outline?
      end

      # Check if outline effect is enabled
      def outline?
        val = outline_level
        return false if val.nil?

        val = val.value if val.respond_to?(:value)
        # Handle both boolean and integer values
        val == true || val == 1 || val.to_i == 1
      end

      # Set outline effect
      def outline=(value)
        self.outline_level = value.is_a?(Properties::OutlineLevel) ? value : Properties::OutlineLevel.new(value: value)
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

      # Initialize with defaults
      def initialize(attrs = {})
        super
        # Use ||= to not override parsed values (Pattern 0)
        @character_spacing = @spacing if @spacing
      end
    end
  end
end
