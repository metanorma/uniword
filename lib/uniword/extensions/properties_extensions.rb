# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    # ParagraphProperties extensions for fluent interface
    class ParagraphProperties
      # Set alignment (fluent interface)
      #
      # @param value [String, Symbol] Alignment (left, center, right, justify)
      # @return [self] For method chaining
      def align(value)
        self.alignment = value.to_s
        self
      end

      # Set spacing before (fluent interface)
      #
      # @param value [Integer] Spacing in twips
      # @return [self] For method chaining
      def before(value)
        self.spacing_before = value
        self
      end

      # Set spacing after (fluent interface)
      #
      # @param value [Integer] Spacing in twips
      # @return [self] For method chaining
      def after(value)
        self.spacing_after = value
        self
      end

      # Set line spacing (fluent interface)
      #
      # @param value [Float] Line spacing multiplier
      # @param rule [String] Line rule (auto, exact, atLeast)
      # @return [self] For method chaining
      def line(value, rule = 'auto')
        self.line_spacing = value
        self.line_rule = rule
        self
      end

      # Set left indent (fluent interface)
      #
      # @param value [Integer] Indent in twips
      # @return [self] For method chaining
      def left(value)
        self.indent_left = value
        self
      end

      # Set right indent (fluent interface)
      #
      # @param value [Integer] Indent in twips
      # @return [self] For method chaining
      def right(value)
        self.indent_right = value
        self
      end

      # Set first line indent (fluent interface)
      #
      # @param value [Integer] Indent in twips
      # @return [self] For method chaining
      def first_line(value)
        self.indent_first_line = value
        self
      end
    end

    # RunProperties extensions for fluent interface
    class RunProperties
      # Set bold (fluent interface)
      #
      # @param value [Boolean] true for bold
      # @return [self] For method chaining
      def set_bold(value = true)
        self.bold = value
        self
      end

      # Set italic (fluent interface)
      #
      # @param value [Boolean] true for italic
      # @return [self] For method chaining
      def set_italic(value = true)
        self.italic = value
        self
      end

      # Set underline (fluent interface)
      #
      # @param value [String, Boolean] Underline type or true for 'single'
      # @return [self] For method chaining
      def set_underline(value = true)
        self.underline = value == true ? 'single' : value.to_s
        self
      end

      # Set color (fluent interface)
      #
      # @param value [String] Hex color
      # @return [self] For method chaining
      def set_color(value)
        self.color = value
        self
      end

      # Set font (fluent interface)
      #
      # @param value [String] Font name
      # @return [self] For method chaining
      def set_font(value)
        self.font = value
        self
      end

      # Set size in points (fluent interface)
      #
      # @param value [Integer] Size in points
      # @return [self] For method chaining
      def set_size(value)
        self.sz = value * 2 # Convert to half-points
        self
      end

      # Set strike-through (fluent interface)
      #
      # @param value [Boolean] true for strike-through
      # @return [self] For method chaining
      def set_strike(value = true)
        self.strike = value
        self
      end

      # Set highlight (fluent interface)
      #
      # @param value [String] Highlight color
      # @return [self] For method chaining
      def set_highlight(value)
        self.highlight = value
        self
      end
    end

    # TableProperties extensions for fluent interface
    class TableProperties
      # Set table width (fluent interface)
      #
      # @param value [Integer] Width value
      # @param type [String] Width type (pct, dxa, auto)
      # @return [self] For method chaining
      def width(value, type = 'dxa')
        self.width_value = value
        self.width_type = type
        self
      end

      # Set table alignment (fluent interface)
      #
      # @param value [String, Symbol] Alignment (left, center, right)
      # @return [self] For method chaining
      def align(value)
        self.alignment = value.to_s
        self
      end
    end
  end
end
