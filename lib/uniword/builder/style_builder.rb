# frozen_string_literal: true

module Uniword
  module Builder
    # Builds and configures Style objects.
    #
    # @example Define a heading style
    #   doc.define_style('MyHeading', base_on: 'Heading1') do |s|
    #     s.font_size(28)
    #     s.bold(true)
    #     s.color('2E74B5')
    #   end
    class StyleBuilder
      attr_reader :model

      def initialize(name, base_on: "Normal")
        @model = Wordprocessingml::Style.new
        @model.styleId = name.tr(" ", "")
        @model.name = Wordprocessingml::StyleName.new(val: name)
        @model.basedOn = Wordprocessingml::BasedOn.new(val: base_on)
      end

      # Wrap an existing Style model
      def self.from_model(model)
        base = model.basedOn&.val || "Normal"
        new(model.name&.val || model.name.to_s, base_on: base)
      end

      # Set style type
      #
      # @param value [String] 'paragraph' or 'character'
      # @return [self]
      def type=(value)
        @model.type = value
        self
      end

      # Set font size in points
      #
      # @param points [Integer] Font size in points
      # @return [self]
      def font_size(points)
        ensure_run_props
        @model.rPr.size = Properties::FontSize.new(value: points.to_i * 2)
        self
      end

      # Set bold
      #
      # @param value [Boolean] Bold state (default true)
      # @return [self]
      def bold(value = true)
        ensure_run_props
        @model.rPr.bold = Properties::Bold.new(value: value)
        self
      end

      # Set italic
      #
      # @param value [Boolean] Italic state (default true)
      # @return [self]
      def italic(value = true)
        ensure_run_props
        @model.rPr.italic = Properties::Italic.new(value: value)
        self
      end

      # Set font color
      #
      # @param value [String] Color as hex string
      # @return [self]
      def color(value)
        ensure_run_props
        @model.rPr.color = Properties::ColorValue.new(value: value)
        self
      end

      # Set font name
      #
      # @param value [String] Font family
      # @return [self]
      def font(value)
        ensure_run_props
        @model.rPr.font = value
        self
      end

      # Set paragraph alignment
      #
      # @param value [String] :left, :center, :right, :justify
      # @return [self]
      def align(value)
        ensure_para_props
        @model.pPr.alignment = value.to_s
        self
      end

      # Set paragraph spacing
      #
      # @param before [Integer, nil] Spacing before in twips
      # @param after [Integer, nil] Spacing after in twips
      # @param line [Integer, nil] Line spacing in twips
      # @return [self]
      def spacing(before: nil, after: nil, line: nil)
        ensure_para_props
        @model.pPr.spacing ||= Properties::Spacing.new
        @model.pPr.spacing.before = before if before
        @model.pPr.spacing.after = after if after
        @model.pPr.spacing.line = line if line
        self
      end

      # Return the underlying Style model
      def build
        @model
      end

      private

      def ensure_run_props
        @model.rPr ||= Wordprocessingml::RunProperties.new
      end

      def ensure_para_props
        @model.pPr ||= Wordprocessingml::ParagraphProperties.new
      end
    end
  end
end
