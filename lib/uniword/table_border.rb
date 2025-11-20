# frozen_string_literal: true

require "lutaml/model"

module Uniword
  # Represents a table border configuration
  # Used for table and cell borders
  class TableBorder < Lutaml::Model::Serializable
    attribute :style, :string, default: -> { "single" }
    attribute :width, :integer, default: -> { 4 }
    attribute :color, :string, default: -> { "auto" }
    attribute :space, :integer, default: -> { 0 }

    # Valid border styles
    STYLES = %w[
      none
      single
      thick
      double
      dotted
      dashed
      dotDash
      dotDotDash
      triple
      thinThickSmallGap
      thickThinSmallGap
      thinThickThinSmallGap
      thinThickMediumGap
      thickThinMediumGap
      thinThickThinMediumGap
      thinThickLargeGap
      thickThinLargeGap
      thinThickThinLargeGap
      wave
      doubleWave
      dashSmallGap
      dashDotStroked
      threeDEmboss
      threeDEngrave
      outset
      inset
    ].freeze

    def initialize(**attributes)
      super
      validate_style
    end

    # Create a simple single border
    def self.single(width: 4, color: "auto")
      new(style: "single", width: width, color: color)
    end

    # Create a double border
    def self.double(width: 6, color: "auto")
      new(style: "double", width: width, color: color)
    end

    # Create a dashed border
    def self.dashed(width: 4, color: "auto")
      new(style: "dashed", width: width, color: color)
    end

    # Create a dotted border
    def self.dotted(width: 4, color: "auto")
      new(style: "dotted", width: width, color: color)
    end

    # Create a thick border
    def self.thick(color: "auto")
      new(style: "thick", width: 8, color: color)
    end

    # Create no border
    def self.none
      new(style: "none", width: 0, color: "auto")
    end

    private

    def validate_style
      return unless style && !STYLES.include?(style)

      raise ArgumentError, "Invalid border style: #{style}. Must be one of: #{STYLES.join(', ')}"
    end
  end
end