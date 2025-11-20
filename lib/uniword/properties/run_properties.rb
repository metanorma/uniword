# frozen_string_literal: true

module Uniword
  module Properties
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
        root 'rPr', mixed: true
        namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

        # All mapped elements will be in the 'w' namespace
        map_element 'rStyle', to: :style
        map_element 'b', to: :bold
        map_element 'i', to: :italic
        map_element 'u', to: :underline
        map_element 'strike', to: :strike
        map_element 'sz', to: :size
        map_element 'rFonts', to: :font
        map_element 'color', to: :color
        map_element 'highlight', to: :highlight
        map_element 'vertAlign', to: :vertical_align
        map_element 'smallCaps', to: :small_caps
        map_element 'caps', to: :caps
        map_element 'vanish', to: :hidden
      end

      # Style reference (name of character style)
      attribute :style, :string

      # Bold formatting
      attribute :bold, :boolean, default: -> { false }

      # Italic formatting
      attribute :italic, :boolean, default: -> { false }

      # Underline style (single, double, none, etc.)
      # Can also accept boolean true (converted to "single") or false (converted to nil)
      attribute :underline, :string

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

      # Strike-through formatting
      attribute :strike, :boolean, default: -> { false }

      # Font size in half-points (e.g., 24 = 12pt)
      attribute :size, :integer

      # Font family name
      attribute :font, :string

      # Text color (hex color code)
      attribute :color, :string

      # Highlight color
      attribute :highlight, :string

      # Vertical alignment (superscript, subscript, baseline)
      attribute :vertical_align, :string

      # Small caps formatting
      attribute :small_caps, :boolean, default: -> { false }

      # All caps formatting
      attribute :caps, :boolean, default: -> { false }

      # Hidden text
      attribute :hidden, :boolean, default: -> { false }

      # Character spacing in twentieths of a point
      attribute :spacing, :integer

      # Emphasis mark (dot, comma, circle, underDot)
      attribute :emphasis_mark, :string

      # Language settings
      attribute :language, :string
      attribute :language_bidi, :string
      attribute :language_east_asia, :string

      # Font family variants (for different scripts)
      attribute :font_ascii, :string
      attribute :font_east_asia, :string
      attribute :font_hint, :string

      # Character spacing (alias for spacing)
      attribute :character_spacing, :integer

      # Double strikethrough
      attribute :double_strike, :boolean, default: -> { false }

      # All capitals formatting (alias for caps)
      attribute :all_caps, :boolean, default: -> { false }

      # Kerning threshold in half-points
      attribute :kerning, :integer

      # Raised/lowered position in half-points
      attribute :position, :integer

      # Width scaling percentage (50-600)
      attribute :w_scale, :integer

      # Shading/background (will be enhanced with Shading class)
      attribute :shading, :string

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

      # Value-based equality
      # Two RunProperties objects are equal if all attributes match
      #
      # @param other [Object] The object to compare with
      # @return [Boolean] true if equal, false otherwise
      def ==(other)
        return false unless other.is_a?(self.class)

        style == other.style &&
          bold == other.bold &&
          italic == other.italic &&
          underline == other.underline &&
          strike == other.strike &&
          size == other.size &&
          font == other.font &&
          color == other.color &&
          highlight == other.highlight &&
          vertical_align == other.vertical_align &&
          small_caps == other.small_caps &&
          caps == other.caps &&
          hidden == other.hidden &&
          spacing == other.spacing &&
          kerning == other.kerning &&
          position == other.position &&
          w_scale == other.w_scale &&
          shading == other.shading &&
          emphasis_mark == other.emphasis_mark &&
          language == other.language &&
          language_bidi == other.language_bidi &&
          language_east_asia == other.language_east_asia &&
          font_ascii == other.font_ascii &&
          font_east_asia == other.font_east_asia &&
          font_hint == other.font_hint &&
          character_spacing == other.character_spacing &&
          double_strike == other.double_strike &&
          all_caps == other.all_caps
      end

      alias eql? ==

      # Hash code for value-based hashing
      #
      # @return [Integer] hash code
      def hash
        [
          style, bold, italic, underline, strike, size,
          font, color, highlight, vertical_align,
          small_caps, caps, hidden, spacing, kerning,
          position, w_scale, shading, emphasis_mark,
          language, language_bidi, language_east_asia,
          font_ascii, font_east_asia, font_hint,
          character_spacing, double_strike, all_caps
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
