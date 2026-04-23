# frozen_string_literal: true

require "lutaml/model"

module Uniword
  # Represents a single paragraph border side
  #
  # @attr [String] style Border style (single, thick, double, etc.)
  # @attr [String] color Border color (hex)
  # @attr [Integer] size Border width in eighths of a point
  # @attr [Integer] space Space from text in points
  class ParagraphBorderSide < Lutaml::Model::Serializable
    # Border styles matching OOXML specification
    STYLES = %w[
      single thick double dotted dashed
      dotDash dotDotDash triple
      thinThickSmallGap thickThinSmallGap
      thinThickThinSmallGap thinThickMediumGap
      thickThinMediumGap thinThickThinMediumGap
      thinThickLargeGap thickThinLargeGap
      thinThickThinLargeGap wave doubleWave
      dashSmallGap dashDotStroked threeDEmboss
      threeDEngrave outset inset
    ].freeze

    attribute :style, :string, default: -> { "single" }
    attribute :color, :string, default: -> { "auto" }
    attribute :size, :integer, default: -> { 6 }
    attribute :space, :integer, default: -> { 1 }

    def initialize(**attributes)
      super
      validate_style
    end

    private

    def validate_style
      return unless style && !STYLES.include?(style)

      raise ArgumentError,
            "Invalid border style: #{style}. Must be one of: #{STYLES.join(', ')}"
    end
  end

  # Represents paragraph borders
  #
  # Paragraph borders can be applied to individual sides or between paragraphs.
  #
  # @example Create paragraph with borders
  #   borders = ParagraphBorders.new
  #   borders.top = ParagraphBorderSide.new(style: 'single', color: '000000', size: 6)
  #   borders.bottom = ParagraphBorderSide.new(style: 'double', color: 'FF0000', size: 12)
  #
  # @attr [ParagraphBorderSide] top Top border
  # @attr [ParagraphBorderSide] bottom Bottom border
  # @attr [ParagraphBorderSide] left Left border
  # @attr [ParagraphBorderSide] right Right border
  # @attr [ParagraphBorderSide] between Border between paragraphs
  class ParagraphBorders < Lutaml::Model::Serializable
    attribute :top, ParagraphBorderSide
    attribute :bottom, ParagraphBorderSide
    attribute :left, ParagraphBorderSide
    attribute :right, ParagraphBorderSide
    attribute :between, ParagraphBorderSide

    # Create borders on all sides with same properties
    #
    # @param style [String] Border style
    # @param color [String] Border color
    # @param size [Integer] Border size
    # @param space [Integer] Space from text
    # @return [ParagraphBorders] New instance
    def self.all_sides(style: "single", color: "auto", size: 6, space: 1)
      border_side = ParagraphBorderSide.new(
        style: style,
        color: color,
        size: size,
        space: space,
      )
      new(
        top: border_side,
        bottom: border_side,
        left: border_side,
        right: border_side,
      )
    end

    # Create box borders (all sides, no between)
    #
    # @param style [String] Border style
    # @param color [String] Border color
    # @param size [Integer] Border size
    # @param space [Integer] Space from text
    # @return [ParagraphBorders] New instance
    def self.box(style: "single", color: "auto", size: 6, space: 1)
      all_sides(style: style, color: color, size: size, space: space)
    end

    # Check if any border is defined
    #
    # @return [Boolean] true if any border exists
    def any?
      !top.nil? || !bottom.nil? || !left.nil? || !right.nil? || !between.nil?
    end

    # Check if this creates a complete box
    #
    # @return [Boolean] true if all four sides are defined
    def box?
      !top.nil? && !bottom.nil? && !left.nil? && !right.nil?
    end
  end
end
