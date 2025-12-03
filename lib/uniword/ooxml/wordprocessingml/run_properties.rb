# frozen_string_literal: true

require 'lutaml/model'
require_relative '../../properties/run_fonts'
require_relative '../../properties/font_size'
require_relative '../../properties/color_value'
require_relative '../../properties/style_reference'
require_relative '../../properties/underline'
require_relative '../../properties/highlight'
require_relative '../../properties/vertical_align'
require_relative '../../properties/position'
require_relative '../../properties/character_spacing'
require_relative '../../properties/kerning'
require_relative '../../properties/width_scale'
require_relative '../../properties/emphasis_mark'
require_relative '../../properties/shading'
require_relative '../../properties/language'
require_relative '../../properties/text_fill'
require_relative '../../properties/text_outline'

module Uniword
  module Ooxml
    module WordProcessingML
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

        # Boolean formatting
        attribute :bold, :boolean, default: -> { false }
        attribute :italic, :boolean, default: -> { false }
        attribute :strike, :boolean, default: -> { false }
        attribute :double_strike, :boolean, default: -> { false }
        attribute :small_caps, :boolean, default: -> { false }
        attribute :caps, :boolean, default: -> { false }
        attribute :all_caps, :boolean, default: -> { false } # Alias for caps
        attribute :hidden, :boolean, default: -> { false }
        attribute :no_proof, :boolean, default: -> { false } # Disable spell/grammar check

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

          # Boolean formatting (only render if true)
          map_element 'b', to: :bold, render_nil: false, render_default: false
          map_element 'i', to: :italic, render_nil: false, render_default: false
          map_element 'strike', to: :strike, render_nil: false, render_default: false
          map_element 'dstrike', to: :double_strike, render_nil: false, render_default: false
          map_element 'smallCaps', to: :small_caps, render_nil: false, render_default: false
          map_element 'caps', to: :caps, render_nil: false, render_default: false
          map_element 'vanish', to: :hidden, render_nil: false, render_default: false
          map_element 'noProof', to: :no_proof, render_nil: false, render_default: false

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
          @no_proof ||= false
          @character_spacing = @spacing if @spacing
        end
      end
    end
  end
end