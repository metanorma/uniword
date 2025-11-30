# frozen_string_literal: true

require 'lutaml/model'
require_relative 'run_fonts'
require_relative 'font_size'
require_relative 'color_value'
require_relative 'style_reference'
require_relative 'underline'
require_relative 'highlight'
require_relative 'vertical_align'
require_relative 'position'
require_relative 'character_spacing'
require_relative 'kerning'
require_relative 'width_scale'
require_relative 'emphasis_mark'
require_relative 'shading'
require_relative 'language'
require_relative 'text_fill'
require_relative 'text_outline'

module Uniword
  module Properties
    # Run (character) formatting properties
    #
    # Represents w:rPr element containing character-level formatting.
    # Used in StyleSets and run elements.
    class RunProperties < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST, then XML mappings

      # Simple element wrapper objects
      attribute :style, StyleReference
      attribute :size, FontSize
      attribute :size_cs, FontSize
      attribute :color, ColorValue
      attribute :underline, Underline
      attribute :highlight, Highlight
      attribute :vertical_align, VerticalAlign
      attribute :position, Position
      attribute :character_spacing, CharacterSpacing
      attribute :kerning, Kerning
      attribute :width_scale, WidthScale
      attribute :emphasis_mark, EmphasisMark

      # Complex fonts object
      attribute :fonts, RunFonts

      # Complex shading object
      attribute :shading, Shading

      # Complex language object
      attribute :language, Language

      # Complex text effects objects
      attribute :text_fill, TextFill
      attribute :text_outline, TextOutline

      # Boolean formatting
      attribute :bold, :boolean, default: -> { false }
      attribute :italic, :boolean, default: -> { false }
      attribute :strike, :boolean, default: -> { false }
      attribute :double_strike, :boolean, default: -> { false }
      attribute :small_caps, :boolean, default: -> { false }
      attribute :caps, :boolean, default: -> { false }
      attribute :all_caps, :boolean, default: -> { false }  # Alias for caps
      attribute :hidden, :boolean, default: -> { false }

      # Flat attributes (kept as aliases for compatibility)
      attribute :spacing, :integer          # Flat attribute (deprecated)
      attribute :kern, :integer             # Flat attribute (deprecated)
      attribute :w_scale, :integer          # Flat attribute (deprecated)
      attribute :em, :string                # Flat attribute (deprecated)

      # Flat language attributes (deprecated, kept for compatibility)
      attribute :language_val, :string      # Language code (e.g., "en-US")
      attribute :language_bidi, :string     # BiDi language
      attribute :language_east_asia, :string  # East Asian language

      # Flat shading (deprecated, kept for compatibility)
      attribute :shading_fill, :string      # Background fill color (flat)

      # XML mappings come AFTER attributes
      xml do
        element 'rPr'
        namespace Ooxml::Namespaces::WordProcessingML
        mixed_content

        # Style reference (wrapper object)
        map_element 'rStyle', to: :style, render_nil: false

        # Fonts (complex object)
        map_element 'rFonts', to: :fonts, render_nil: false

        # Font sizes (wrapper objects)
        map_element 'sz', to: :size, render_nil: false
        map_element 'szCs', to: :size_cs, render_nil: false

        # Boolean formatting (only render if true)
        map_element 'b', to: :bold, render_nil: false, render_default: false
        map_element 'i', to: :italic, render_nil: false, render_default: false
        map_element 'strike', to: :strike, render_nil: false, render_default: false
        map_element 'dstrike', to: :double_strike, render_nil: false, render_default: false
        map_element 'smallCaps', to: :small_caps, render_nil: false, render_default: false
        map_element 'caps', to: :caps, render_nil: false, render_default: false
        map_element 'vanish', to: :hidden, render_nil: false, render_default: false

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
      end

      # Initialize with defaults
      def initialize(attrs = {})
        super
        @bold ||= false
        @italic ||= false
        @strike ||= false
        @double_strike ||= false
        @small_caps ||= false
        @caps ||= false
        @all_caps ||= false
        @hidden ||= false
        @character_spacing = @spacing if @spacing
      end
    end
  end
end