# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  # Represents a single page border side
  #
  # @attr [String] style Border style (single, thick, double, etc.)
  # @attr [String] color Border color (hex)
  # @attr [Integer] width Border width in eighths of a point
  # @attr [Integer] space Space from text in points
  class PageBorderSide < Lutaml::Model::Serializable
    # Border styles
    STYLES = %w[
      single thick double dotted dashed
      dot_dash triple wave dashSmallGap
      dashDotStroked threeDEmboss threeDEngrave
    ].freeze

    attribute :style, :string, default: -> { 'single' }
    attribute :color, :string, default: -> { 'auto' }
    attribute :width, :integer, default: -> { 6 }
    attribute :space, :integer, default: -> { 0 }

    def initialize(**attributes)
      super
      validate_style
    end

    private

    def validate_style
      return unless style && !STYLES.include?(style)

      raise ArgumentError, "Invalid border style: #{style}. Must be one of: #{STYLES.join(', ')}"
    end
  end

  # Represents page borders for a section
  #
  # Page borders can be applied to all sides of pages in a section.
  #
  # @example Create page borders
  #   borders = PageBorders.new(
  #     display: 'allPages',
  #     offset_from: 'page'
  #   )
  #   borders.top = PageBorderSide.new(style: 'double', color: '000000', width: 12)
  #
  # @attr [PageBorderSide] top Top border
  # @attr [PageBorderSide] bottom Bottom border
  # @attr [PageBorderSide] left Left border
  # @attr [PageBorderSide] right Right border
  # @attr [String] display When to display borders (allPages, firstPage, notFirstPage)
  # @attr [String] offset_from Measurement reference (page, text)
  class PageBorders < Lutaml::Model::Serializable
    # Display options
    DISPLAY_OPTIONS = %w[allPages firstPage notFirstPage].freeze

    # Offset reference options
    OFFSET_OPTIONS = %w[page text].freeze

    attribute :top, PageBorderSide
    attribute :bottom, PageBorderSide
    attribute :left, PageBorderSide
    attribute :right, PageBorderSide
    attribute :display, :string, default: -> { 'allPages' }
    attribute :offset_from, :string, default: -> { 'page' }

    def initialize(**attributes)
      super
      validate_display
      validate_offset_from
    end

    # Create borders on all sides with same properties
    #
    # @param style [String] Border style
    # @param color [String] Border color
    # @param width [Integer] Border width
    # @param options [Hash] Additional options (display, offset_from)
    # @return [PageBorders] New instance
    def self.all_sides(style: 'single', color: 'auto', width: 6, **)
      border_side = PageBorderSide.new(style: style, color: color, width: width)
      new(
        top: border_side,
        bottom: border_side,
        left: border_side,
        right: border_side,
        **
      )
    end

    # Check if any border is defined
    #
    # @return [Boolean] true if any border exists
    def any?
      !top.nil? || !bottom.nil? || !left.nil? || !right.nil?
    end

    private

    def validate_display
      return unless display && !DISPLAY_OPTIONS.include?(display)

      raise ArgumentError,
            "Invalid display: #{display}. Must be one of: #{DISPLAY_OPTIONS.join(', ')}"
    end

    def validate_offset_from
      return unless offset_from && !OFFSET_OPTIONS.include?(offset_from)

      raise ArgumentError,
            "Invalid offset_from: #{offset_from}. Must be one of: #{OFFSET_OPTIONS.join(', ')}"
    end
  end
end
