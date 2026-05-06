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
    class RunBuilder < BaseBuilder
      include HasShading

      def self.default_model_class
        Wordprocessingml::Run
      end

      def text(value)
        @model.text = value
        self
      end

      def bold(value = true)
        ensure_properties.bold = Properties::Bold.new(value: value)
        self
      end

      def italic(value = true)
        ensure_properties.italic = Properties::Italic.new(value: value)
        self
      end

      def underline(value = "single")
        val = value == true ? "single" : value.to_s
        ensure_properties.underline = Properties::Underline.new(value: val)
        self
      end

      def color(value)
        ensure_properties.color = Properties::ColorValue.new(value: value.to_s)
        self
      end

      def font(value)
        ensure_properties.font = value
        self
      end

      def size(points)
        ensure_properties.size = Properties::FontSize.new(value: points.to_i * 2)
        self
      end

      def highlight(value)
        ensure_properties.highlight = Properties::Highlight.new(value: value.to_s)
        self
      end

      def strike(value = true)
        ensure_properties.strike = Properties::Strike.new(value: value)
        self
      end

      def double_strike(value = true)
        ensure_properties.double_strike = Properties::DoubleStrike.new(value: value)
        self
      end

      def small_caps(value = true)
        ensure_properties.small_caps = Properties::SmallCaps.new(value: value)
        self
      end

      def caps(value = true)
        ensure_properties.caps = Properties::Caps.new(value: value)
        self
      end

      def superscript
        ensure_properties.vertical_align = Properties::VerticalAlign.new(value: "superscript")
        self
      end

      def subscript
        ensure_properties.vertical_align = Properties::VerticalAlign.new(value: "subscript")
        self
      end

      def shadow(value = true)
        ensure_properties.shadow = Properties::Shadow.new(value: value)
        self
      end

      def emboss(value = true)
        ensure_properties.emboss = Properties::Emboss.new(value: value)
        self
      end

      def imprint(value = true)
        ensure_properties.imprint = Properties::Imprint.new(value: value)
        self
      end

      def outline(value = true)
        ensure_properties.outline = Properties::Outline.new(value: value)
        self
      end

      def kerning(value)
        ensure_properties.kerning = Properties::Kerning.new(value: value)
        self
      end

      def character_spacing(value)
        ensure_properties.character_spacing = Properties::CharacterSpacing.new(value: value)
        self
      end

      def text_expansion(value)
        ensure_properties.width_scale = Properties::WidthScale.new(value: value)
        self
      end

      def language(code)
        ensure_properties.language = Properties::Language.new(val: code)
        self
      end

      def emphasis_mark(value)
        ensure_properties.emphasis_mark = Properties::EmphasisMark.new(value: value)
        self
      end

      def position(value)
        ensure_properties.position = Properties::Position.new(value: value)
        self
      end

      # Add a Drawing to the run
      #
      # @param drawing [Wordprocessingml::Drawing] Drawing element
      # @return [self]
      def drawing(drawing)
        @model.drawings << drawing
        self
      end

      private

      def ensure_properties
        @model.properties ||= Wordprocessingml::RunProperties.new
        @model.properties
      end
    end
  end
end
