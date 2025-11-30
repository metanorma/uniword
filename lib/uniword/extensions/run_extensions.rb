# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    class Run
      # Check if run is bold
      #
      # @return [Boolean] true if bold
      def bold?
        properties&.bold || false
      end

      # Check if run is italic
      #
      # @return [Boolean] true if italic
      def italic?
        properties&.italic || false
      end

      # Check if run is underlined
      #
      # @return [Boolean] true if underlined
      def underline?
        properties&.underline && properties.underline != 'none'
      end

      # Set bold formatting
      #
      # @param value [Boolean] true for bold
      # @return [self] For method chaining
      def bold=(value)
        self.properties ||= RunProperties.new
        properties.bold = value
        self
      end

      # Set italic formatting
      #
      # @param value [Boolean] true for italic
      # @return [self] For method chaining
      def italic=(value)
        self.properties ||= RunProperties.new
        properties.italic = value
        self
      end

      # Set underline formatting
      #
      # @param value [String, Boolean] Underline type or true for 'single'
      # @return [self] For method chaining
      def underline=(value)
        self.properties ||= RunProperties.new
        properties.underline = value == true ? 'single' : value.to_s
        self
      end

      # Set text color
      #
      # @param value [String] Hex color (e.g., 'FF0000')
      # @return [self] For method chaining
      def color=(value)
        self.properties ||= RunProperties.new
        properties.color = value
        self
      end

      # Set font
      #
      # @param value [String] Font name
      # @return [self] For method chaining
      def font=(value)
        self.properties ||= RunProperties.new
        properties.font = value
        self
      end

      # Set font size in points
      #
      # @param value [Integer] Size in points
      # @return [self] For method chaining
      def size=(value)
        self.properties ||= RunProperties.new
        properties.sz = value * 2 # Convert to half-points
        self
      end

      # Set strike-through formatting
      #
      # @param value [Boolean] true for strike-through
      # @return [self] For method chaining
      def strike=(value)
        self.properties ||= RunProperties.new
        properties.strike = value
        self
      end

      # Set double-strike-through formatting
      #
      # @param value [Boolean] true for double strike-through
      # @return [self] For method chaining
      def double_strike=(value)
        self.properties ||= RunProperties.new
        properties.double_strike = value
        self
      end

      # Set small caps formatting
      #
      # @param value [Boolean] true for small caps
      # @return [self] For method chaining
      def small_caps=(value)
        self.properties ||= RunProperties.new
        properties.small_caps = value
        self
      end

      # Set all caps formatting
      #
      # @param value [Boolean] true for all caps
      # @return [self] For method chaining
      def caps=(value)
        self.properties ||= RunProperties.new
        properties.caps = value
        self
      end

      # Set highlight color
      #
      # @param value [String] Highlight color (e.g., 'yellow', 'cyan')
      # @return [self] For method chaining
      def highlight=(value)
        self.properties ||= RunProperties.new
        properties.highlight = value
        self
      end

      # Set vertical alignment (superscript/subscript)
      #
      # @param value [String] 'superscript', 'subscript', or 'baseline'
      # @return [self] For method chaining
      def vert_align=(value)
        self.properties ||= RunProperties.new
        properties.vert_align = value
        self
      end
    end
  end
end
