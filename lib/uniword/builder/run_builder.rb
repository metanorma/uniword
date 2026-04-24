# frozen_string_literal: true

module Uniword
  module Builder
    # Builds and configures Run objects with formatting.
    #
    # @example Create a formatted run
    #   run = RunBuilder.new.bold.italic.color('FF0000').size(12).build
    #
    # @example Wrap an existing run
    #   builder = RunBuilder.from_model(existing_run)
    #   builder.bold.build
    class RunBuilder
      attr_reader :model

      def initialize(model = nil)
        @model = model || Wordprocessingml::Run.new
      end

      # Wrap an existing Run model for manipulation
      #
      # @param model [Wordprocessingml::Run] Existing run
      # @return [RunBuilder]
      def self.from_model(model)
        new(model)
      end

      # Set text content
      #
      # @param value [String] Text content
      # @return [self]
      def text(value)
        @model.text = value
        self
      end

      # Set bold formatting
      #
      # @param value [Boolean] Bold state (default true)
      # @return [self]
      def bold(value = true)
        ensure_props.bold = Properties::Bold.new(value: value)
        self
      end

      # Set italic formatting
      #
      # @param value [Boolean] Italic state (default true)
      # @return [self]
      def italic(value = true)
        ensure_props.italic = Properties::Italic.new(value: value)
        self
      end

      # Set underline formatting
      #
      # @param value [String, Boolean] Underline style or boolean
      # @return [self]
      def underline(value = "single")
        val = value == true ? "single" : value.to_s
        ensure_props.underline = Properties::Underline.new(value: val)
        self
      end

      # Set font color
      #
      # @param value [String] Color as hex string
      # @return [self]
      def color(value)
        ensure_props.color = Properties::ColorValue.new(value: value.to_s)
        self
      end

      # Set font name
      #
      # @param value [String] Font family name
      # @return [self]
      def font(value)
        ensure_props.font = value
        self
      end

      # Set font size in points
      #
      # @param points [Integer] Font size in points
      # @return [self]
      def size(points)
        ensure_props.size = Properties::FontSize.new(value: points.to_i * 2)
        self
      end

      # Set highlight color
      #
      # @param value [String] Highlight color name
      # @return [self]
      def highlight(value)
        ensure_props.highlight = Properties::Highlight.new(value: value.to_s)
        self
      end

      # Set strikethrough
      #
      # @param value [Boolean] Strike state (default true)
      # @return [self]
      def strike(value = true)
        ensure_props.strike = Properties::Strike.new(value: value)
        self
      end

      # Set double strikethrough
      #
      # @param value [Boolean] Double strike state (default true)
      # @return [self]
      def double_strike(value = true)
        ensure_props.double_strike = Properties::DoubleStrike.new(value: value)
        self
      end

      # Set small caps
      #
      # @param value [Boolean] Small caps state (default true)
      # @return [self]
      def small_caps(value = true)
        ensure_props.small_caps = Properties::SmallCaps.new(value: value)
        self
      end

      # Set all caps
      #
      # @param value [Boolean] Caps state (default true)
      # @return [self]
      def caps(value = true)
        ensure_props.caps = Properties::Caps.new(value: value)
        self
      end

      # Set superscript
      #
      # @return [self]
      def superscript
        ensure_props.vertical_align = Properties::VerticalAlign.new(value: "superscript")
        self
      end

      # Set subscript
      #
      # @return [self]
      def subscript
        ensure_props.vertical_align = Properties::VerticalAlign.new(value: "subscript")
        self
      end

      # Set shading
      #
      # @param fill [String] Fill color
      # @param color [String, nil] Shading color
      # @param pattern [String] Pattern (default 'clear')
      # @return [self]
      def shading(fill:, color: nil, pattern: "clear")
        ensure_props.shading = Properties::Shading.new(
          fill: fill, color: color, pattern: pattern,
        )
        self
      end

      # Set shadow
      #
      # @param value [Boolean] Shadow state (default true)
      # @return [self]
      def shadow(value = true)
        ensure_props.shadow = Properties::Shadow.new(value: value)
        self
      end

      # Set emboss
      #
      # @param value [Boolean] Emboss state (default true)
      # @return [self]
      def emboss(value = true)
        ensure_props.emboss = Properties::Emboss.new(value: value)
        self
      end

      # Set imprint
      #
      # @param value [Boolean] Imprint state (default true)
      # @return [self]
      def imprint(value = true)
        ensure_props.imprint = Properties::Imprint.new(value: value)
        self
      end

      # Set outline
      #
      # @param value [Boolean] Outline state (default true)
      # @return [self]
      def outline(value = true)
        ensure_props.outline = Properties::Outline.new(value: value)
        self
      end

      # Set kerning
      #
      # @param value [Integer] Kerning threshold in half-points
      # @return [self]
      def kerning(value)
        ensure_props.kerning = Properties::Kerning.new(value: value)
        self
      end

      # Set character spacing
      #
      # @param value [Integer] Spacing in twips
      # @return [self]
      def character_spacing(value)
        ensure_props.character_spacing = Properties::CharacterSpacing.new(value: value)
        self
      end

      # Set text expansion (width scale)
      #
      # @param value [Integer] Percentage (e.g., 200 for double width)
      # @return [self]
      def text_expansion(value)
        ensure_props.width_scale = Properties::WidthScale.new(value: value)
        self
      end

      # Set language
      #
      # @param code [String] Language code (e.g., 'en-US')
      # @return [self]
      def language(code)
        ensure_props.language = Properties::Language.new(val: code)
        self
      end

      # Set emphasis mark
      #
      # @param value [String] Emphasis mark type
      # @return [self]
      def emphasis_mark(value)
        ensure_props.emphasis_mark = Properties::EmphasisMark.new(value: value)
        self
      end

      # Set position (superscript/subscript offset)
      #
      # @param value [Integer] Position in half-points
      # @return [self]
      def position(value)
        ensure_props.position = Properties::Position.new(value: value)
        self
      end

      # Add a Drawing to the run
      #
      # @param drawing [Wordprocessingml::Drawing] Drawing element
      # @return [self]
      def drawing(drawing)
        drawings = @model.instance_variable_get(:@drawings) || []
        drawings << drawing
        @model.instance_variable_set(:@drawings, drawings)
        self
      end

      # Return the underlying Run model
      #
      # @return [Wordprocessingml::Run]
      def build
        @model
      end

      private

      # Ensure RunProperties exist on the model
      #
      # @return [Wordprocessingml::RunProperties]
      def ensure_props
        @model.properties ||= Wordprocessingml::RunProperties.new
        @model.properties
      end
    end
  end
end
