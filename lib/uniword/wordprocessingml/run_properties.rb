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

      # Simple element wrapper objects
      attribute :style, Properties::StyleReference
      attribute :size, Properties::FontSize
      attribute :size_cs, Properties::FontSize
      attribute :color, Properties::ColorValue
      attribute :underline, Properties::Underline
      attribute :highlight, Properties::Highlight
      attribute :vertical_align, Properties::VerticalAlign
      attribute :position, Properties::Position
      attribute :character_spacing, Properties::CharacterSpacing
      attribute :kerning, Properties::Kerning
      attribute :width_scale, Properties::WidthScale
      attribute :emphasis_mark, Properties::EmphasisMark

      # Complex fonts object
      attribute :fonts, Properties::RunFonts

      # Complex shading object
      attribute :shading, Properties::Shading

      # Complex language object
      attribute :language, Properties::Language

      # Complex text effects objects
      attribute :text_fill, Properties::TextFill
      attribute :text_outline, Properties::TextOutline

      # Boolean formatting wrapper objects
      attribute :bold, Properties::Bold
      attribute :bold_cs, Properties::BoldCs
      attribute :italic, Properties::Italic
      attribute :italic_cs, Properties::ItalicCs
      attribute :strike, Properties::Strike
      attribute :double_strike, Properties::DoubleStrike
      attribute :small_caps, Properties::SmallCaps
      attribute :caps, Properties::Caps
      attribute :hidden, Properties::Vanish
      attribute :no_proof, Properties::NoProof
      attribute :shadow, Properties::Shadow
      attribute :emboss, Properties::Emboss
      attribute :imprint, Properties::Imprint
      attribute :outline_level, Properties::OutlineLevel

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

      # Flat boolean attributes (convenience for API access)
      attribute :all_caps, :boolean # Alias for caps

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
        val = shadow
        return false if val.nil?

        val = val.value if val.respond_to?(:value)
        val == true
      end

      def imprint?
        val = imprint
        return false if val.nil?

        val = val.value if val.respond_to?(:value)
        val == true
      end

      def emboss?
        val = emboss
        return false if val.nil?

        val = val.value if val.respond_to?(:value)
        val == true
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

      # Initialize with defaults
      def initialize(attrs = {})
        super
        # Use ||= to not override parsed values (Pattern 0)
        @character_spacing = @spacing if @spacing
      end
    end
  end
end
