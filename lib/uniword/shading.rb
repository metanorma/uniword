# frozen_string_literal: true

require "lutaml/model"

module Uniword
  # Represents shading/background pattern for text or paragraphs
  #
  # Shading provides background colors and patterns for text runs
  # or paragraph backgrounds.
  #
  # @example Solid background
  #   shading = Shading.new(type: 'clear', fill: 'FFFF00')
  #
  # @example Pattern background
  #   shading = Shading.new(
  #     type: 'diagStripe',
  #     color: '0000FF',
  #     fill: 'FFFF00'
  #   )
  #
  # @attr [String] type Shading pattern type
  # @attr [String] color Foreground color (for patterns)
  # @attr [String] fill Background fill color
  class Shading < Lutaml::Model::Serializable
    # Shading pattern types
    TYPES = %w[
      clear solid horzStripe vertStripe
      reverseDiagStripe diagStripe horzCross
      diagCross thinHorzStripe thinVertStripe
      thinReverseDiagStripe thinDiagStripe
      thinHorzCross thinDiagCross
      pct5 pct10 pct12 pct15 pct20 pct25
      pct30 pct35 pct37 pct40 pct45 pct50
      pct55 pct60 pct62 pct65 pct70 pct75
      pct80 pct85 pct87 pct90 pct95
    ].freeze

    attribute :type, :string, default: -> { "clear" }
    attribute :color, :string, default: -> { "auto" }
    attribute :fill, :string

    def initialize(**attributes)
      super
      validate_type
    end

    # Create solid shading with fill color
    #
    # @param fill [String] Fill color (hex)
    # @return [Shading] New instance
    def self.solid(fill)
      new(type: "clear", fill: fill)
    end

    # Create pattern shading
    #
    # @param type [String] Pattern type
    # @param color [String] Foreground color
    # @param fill [String] Background color
    # @return [Shading] New instance
    def self.pattern(type, color: "auto", fill: nil)
      new(type: type, color: color, fill: fill)
    end

    # Create horizontal stripe pattern
    #
    # @param color [String] Stripe color
    # @param fill [String] Background color
    # @return [Shading] New instance
    def self.horizontal_stripe(color: "000000", fill: "FFFFFF")
      new(type: "horzStripe", color: color, fill: fill)
    end

    # Create vertical stripe pattern
    #
    # @param color [String] Stripe color
    # @param fill [String] Background color
    # @return [Shading] New instance
    def self.vertical_stripe(color: "000000", fill: "FFFFFF")
      new(type: "vertStripe", color: color, fill: fill)
    end

    # Create diagonal stripe pattern
    #
    # @param color [String] Stripe color
    # @param fill [String] Background color
    # @return [Shading] New instance
    def self.diagonal_stripe(color: "000000", fill: "FFFFFF")
      new(type: "diagStripe", color: color, fill: fill)
    end

    # Create reverse diagonal stripe pattern
    #
    # @param color [String] Stripe color
    # @param fill [String] Background color
    # @return [Shading] New instance
    def self.reverse_diagonal_stripe(color: "000000", fill: "FFFFFF")
      new(type: "reverseDiagStripe", color: color, fill: fill)
    end

    private

    def validate_type
      return unless type && !TYPES.include?(type)

      raise ArgumentError, "Invalid shading type: #{type}. Must be one of: #{TYPES.join(", ")}"
    end
  end
end
