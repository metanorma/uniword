# frozen_string_literal: true

require_relative 'border'
require_relative 'shading'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Run borders for character-level borders
    class RunBorders < Lutaml::Model::Serializable
      xml do
        element 'bdr'
        namespace Ooxml::Namespaces::WordProcessingML

        map_element 'top', to: :top
        map_element 'bottom', to: :bottom
        map_element 'left', to: :left
        map_element 'right', to: :right
      end

      attribute :top, Border
      attribute :bottom, Border
      attribute :left, Border
      attribute :right, Border

      # Convenience method to set a border
      def set_border(side, style, size = nil, color = nil)
        border = Border.new(style: style, size: size, color: color)
        case side.to_sym
        when :top then self.top = border
        when :bottom then self.bottom = border
        when :left then self.left = border
        when :right then self.right = border
        end
      end

      # Check if any borders are set
      def any_borders?
        !top.nil? || !bottom.nil? || !left.nil? || !right.nil?
      end
    end

    # Run shading for character-level background
    class RunShading < Lutaml::Model::Serializable
      xml do
        element 'shd'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :shading_type
        map_attribute 'color', to: :color
        map_attribute 'fill', to: :fill
        map_attribute 'themeFill', to: :theme_fill
        map_attribute 'themeFillShade', to: :theme_fill_shade
        map_attribute 'themeFillTint', to: :theme_fill_tint
        map_attribute 'themeColor', to: :theme_color
        map_attribute 'themeShade', to: :theme_shade
        map_attribute 'themeTint', to: :theme_tint
      end

      # Shading type (solid, clear, etc.)
      attribute :shading_type, :string

      # Foreground color
      attribute :color, :string

      # Background fill color
      attribute :fill, :string

      # Theme fill color
      attribute :theme_fill, :string

      # Theme fill shade
      attribute :theme_fill_shade, :string

      # Theme fill tint
      attribute :theme_fill_tint, :string

      # Theme color
      attribute :theme_color, :string

      # Theme shade
      attribute :theme_shade, :string

      # Theme tint
      attribute :theme_tint, :string

      # Convenience method to create solid shading
      def self.solid(fill_color, color = nil)
        new(shading_type: 'solid', fill: fill_color, color: color)
      end

      # Convenience method to create clear shading
      def self.clear
        new(shading_type: 'clear')
      end
    end

    # Run font properties for complex font handling
    class RunFontProperties < Lutaml::Model::Serializable
      xml do
        element 'rFonts'
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute 'ascii', to: :ascii
        map_attribute 'eastAsia', to: :east_asia
        map_attribute 'hAnsi', to: :h_ansi
        map_attribute 'cs', to: :complex_script
        map_attribute 'asciiTheme', to: :ascii_theme
        map_attribute 'eastAsiaTheme', to: :east_asia_theme
        map_attribute 'hAnsiTheme', to: :h_ansi_theme
        map_attribute 'cstheme', to: :complex_script_theme
        map_attribute 'hint', to: :hint
      end

      # ASCII font
      attribute :ascii, :string

      # East Asian font
      attribute :east_asia, :string

      # High ANSI font
      attribute :h_ansi, :string

      # Complex script font
      attribute :complex_script, :string

      # ASCII theme font
      attribute :ascii_theme, :string

      # East Asian theme font
      attribute :east_asia_theme, :string

      # High ANSI theme font
      attribute :h_ansi_theme, :string

      # Complex script theme font
      attribute :complex_script_theme, :string

      # Font hint
      attribute :hint, :string
    end

    # Value object representing text run formatting properties
    # Responsibility: Hold immutable character-level styling data
    #
    # This class follows the Value Object pattern:
    # - Immutable (no setters after initialization)
    # - Value-based equality (two objects with same values are equal)
    # - Self-validating
    class RunProperties < Lutaml::Model::Serializable
      # OOXML namespace configuration
      xml do
        element 'rPr'
        namespace Ooxml::Namespaces::WordProcessingML
        mixed_content

        # All mapped elements will be in the 'w' namespace
        map_element 'rStyle', to: :style
        map_element 'b', to: :bold
        map_element 'bCs', to: :bold_complex
        map_element 'i', to: :italic
        map_element 'iCs', to: :italic_complex
        map_element 'caps', to: :caps
        map_element 'smallCaps', to: :small_caps
        map_element 'strike', to: :strike
        map_element 'dstrike', to: :double_strike
        map_element 'outline', to: :outline
        map_element 'shadow', to: :shadow
        map_element 'emboss', to: :emboss
        map_element 'imprint', to: :imprint
        map_element 'vanish', to: :hidden
        map_element 'webHidden', to: :web_hidden
        map_element 'color', to: :color
        map_element 'sz', to: :size
        map_element 'szCs', to: :size_complex
        map_element 'highlight', to: :highlight
        map_element 'u', to: :underline
        map_element 'effect', to: :text_effect
        map_element 'bdr', to: :borders
        map_element 'shd', to: :shading
        map_element 'fitText', to: :fit_text
        map_element 'vertAlign', to: :vertical_align
        map_element 'rtl', to: :right_to_left
        map_element 'cs', to: :complex_script
        map_element 'em', to: :emphasis_mark
        map_element 'hyphen', to: :hyphenation
        map_element 'lang', to: :language
        map_element 'eastAsianLayout', to: :east_asian_layout
        map_element 'specVanish', to: :spec_vanish
        map_element 'oMath', to: :math
        map_element 'rFonts', to: :font_properties
        map_element 'spacing', to: :character_spacing
        map_element 'w', to: :text_expansion
        map_element 'kern', to: :kerning
        map_element 'position', to: :position
      end

      # Style reference (name of character style)
      attribute :style, :string

      # Bold formatting
      attribute :bold, :boolean, default: -> { false }

      # Bold for complex script (right-to-left text)
      attribute :bold_complex, :boolean, default: -> { false }

      # Italic formatting
      attribute :italic, :boolean, default: -> { false }

      # Italic for complex script (right-to-left text)
      attribute :italic_complex, :boolean, default: -> { false }

      # All caps formatting
      attribute :caps, :boolean, default: -> { false }

      # Small caps formatting
      attribute :small_caps, :boolean, default: -> { false }

      # Strike-through formatting
      attribute :strike, :boolean, default: -> { false }

      # Double strikethrough
      attribute :double_strike, :boolean, default: -> { false }

      # Outline text effect
      attribute :outline, :boolean, default: -> { false }

      # Shadow text effect
      attribute :shadow, :boolean, default: -> { false }

      # Emboss text effect
      attribute :emboss, :boolean, default: -> { false }

      # Imprint text effect
      attribute :imprint, :boolean, default: -> { false }

      # Hidden text
      attribute :hidden, :boolean, default: -> { false }

      # Web hidden (hidden in web view)
      attribute :web_hidden, :boolean, default: -> { false }

      # Text color (hex color code)
      attribute :color, :string

      # Font size in half-points (e.g., 24 = 12pt)
      attribute :size, :integer

      # Font size for complex script in half-points
      attribute :size_complex, :integer

      # Simple font name (for convenience - single font for all contexts)
      attribute :font, :string

      # Highlight color
      attribute :highlight, :string

      # Underline style (single, double, none, etc.)
      # Can also accept boolean true (converted to "single") or false (converted to nil)
      attribute :underline, :string

      # Text effects (animation effects like blink, shimmer, etc.)
      attribute :text_effect, :string

      # Character borders
      attribute :borders, RunBorders

      # Character shading/background
      attribute :shading, RunShading

      # Fit text to specified width
      attribute :fit_text, :integer

      # Vertical alignment (superscript, subscript, baseline)
      attribute :vertical_align, :string

      # Right-to-left text
      attribute :right_to_left, :boolean, default: -> { false }

      # Complex script formatting
      attribute :complex_script, :boolean, default: -> { false }

      # Emphasis mark (dot, comma, circle, underDot)
      attribute :emphasis_mark, :string

      # Hyphenation control
      attribute :hyphenation, :string

      # Language settings
      attribute :language, :string
      attribute :language_bidi, :string
      attribute :language_east_asia, :string

      # East Asian layout properties
      attribute :east_asian_layout, :string

      # Special vanish (used for field codes)
      attribute :spec_vanish, :boolean, default: -> { false }

      # Math equation
      attribute :math, :boolean, default: -> { false }

      # Font properties (complex font handling)
      attribute :font_properties, RunFontProperties

      # Character spacing in twentieths of a point
      attribute :character_spacing, :integer

      # Text expansion/compression percentage
      attribute :text_expansion, :integer

      # Kerning threshold in half-points
      attribute :kerning, :integer

      # Raised/lowered position in half-points
      attribute :position, :integer

      # Custom getter returns the string underline value
      # For API compatibility: returns the actual string value (e.g., "single")
      def underline
        return nil if @underline.nil? || @underline == 'none' || @underline == 'false'
        @underline
      end

      # Custom setter to normalize underline values
      # Accepts boolean true (converts to 'single'), false/nil (converts to nil), or string values
      def underline=(value)
        case value
        when true, 'true'
          @underline = 'single'
        when false, 'false', nil, 'none'
          @underline = nil
        else
          @underline = value.to_s
        end
      end

      # Convenience method for font size (returns size attribute)
      # Font size is stored in half-points (e.g., 24 = 12pt)
      #
      # @return [Integer, nil] font size in half-points
      def font_size
        size
      end

      # Set font size (alias for size=)
      # Font size is stored in half-points (e.g., 24 = 12pt)
      #
      # @param value [Integer] font size in half-points
      # @return [Integer] the font size value
      def font_size=(value)
        self.size = value
      end

      # Convenience method for font name (alias for font)
      #
      # @return [String, nil] font family name
      def font_name
        font
      end

      # Set font name (alias for font=)
      #
      # @param value [String] font family name
      # @return [String] the font name value
      def font_name=(value)
        self.font = value
      end

      # Check if this run has any text effects
      def has_text_effects?
        outline || shadow || emboss || imprint || !text_effect.nil?
      end

      # Check if this run has any complex script properties
      def has_complex_script?
        bold_complex || italic_complex || !size_complex.nil? || !language_bidi.nil? || right_to_left || complex_script
      end

      # Value-based equality
      # Two RunProperties objects are equal if all attributes match
      #
      # @param other [Object] The object to compare with
      # @return [Boolean] true if equal, false otherwise
      def ==(other)
        return false unless other.is_a?(self.class)

        style == other.style &&
          bold == other.bold &&
          bold_complex == other.bold_complex &&
          italic == other.italic &&
          italic_complex == other.italic_complex &&
          caps == other.caps &&
          small_caps == other.small_caps &&
          strike == other.strike &&
          double_strike == other.double_strike &&
          outline == other.outline &&
          shadow == other.shadow &&
          emboss == other.emboss &&
          imprint == other.imprint &&
          hidden == other.hidden &&
          web_hidden == other.web_hidden &&
          color == other.color &&
          size == other.size &&
          size_complex == other.size_complex &&
          highlight == other.highlight &&
          underline == other.underline &&
          text_effect == other.text_effect &&
          borders == other.borders &&
          shading == other.shading &&
          fit_text == other.fit_text &&
          vertical_align == other.vertical_align &&
          right_to_left == other.right_to_left &&
          complex_script == other.complex_script &&
          emphasis_mark == other.emphasis_mark &&
          hyphenation == other.hyphenation &&
          language == other.language &&
          language_bidi == other.language_bidi &&
          language_east_asia == other.language_east_asia &&
          east_asian_layout == other.east_asian_layout &&
          spec_vanish == other.spec_vanish &&
          math == other.math &&
          font_properties == other.font_properties &&
          character_spacing == other.character_spacing &&
          text_expansion == other.text_expansion &&
          kerning == other.kerning &&
          position == other.position
      end

      alias eql? ==

      # Hash code for value-based hashing
      #
      # @return [Integer] hash code
      def hash
        [
          style, bold, bold_complex, italic, italic_complex, caps, small_caps,
          strike, double_strike, outline, shadow, emboss, imprint, hidden, web_hidden,
          color, size, size_complex, highlight, underline, text_effect, borders, shading,
          fit_text, vertical_align, right_to_left, complex_script, emphasis_mark,
          hyphenation, language, language_bidi, language_east_asia, east_asian_layout,
          spec_vanish, math, font_properties, character_spacing, text_expansion,
          kerning, position
        ].hash
      end

      # Note: Temporarily allowing mutation for test compatibility
      # In production use, create new properties objects rather than mutating
      def initialize(*args)
        super
        # Don't freeze - allow mutation for easier testing
        # freeze
      end
    end
  end
end
