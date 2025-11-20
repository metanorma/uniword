# frozen_string_literal: true

require "lutaml/model"

module Uniword
  # Represents a text frame for positioned text
  #
  # Text frames allow precise positioning of paragraphs on the page,
  # commonly used for sidebars, pull quotes, and floating text boxes.
  #
  # @example Absolute positioned frame
  #   frame = TextFrame.new(
  #     width: 4000,
  #     height: 1000,
  #     x: 1000,
  #     y: 3000,
  #     h_anchor: 'margin',
  #     v_anchor: 'margin'
  #   )
  #
  # @example Aligned frame
  #   frame = TextFrame.new(
  #     width: 4000,
  #     h_alignment: 'right',
  #     v_alignment: 'top',
  #     h_anchor: 'page',
  #     v_anchor: 'page'
  #   )
  #
  # @attr [Integer] width Frame width in twips
  # @attr [Integer] height Frame height in twips
  # @attr [String] h_rule Width rule (auto, atLeast, exact)
  # @attr [String] w_rule Height rule (auto, atLeast, exact)
  # @attr [Integer] x Horizontal position in twips
  # @attr [Integer] y Vertical position in twips
  # @attr [String] h_anchor Horizontal anchor point
  # @attr [String] v_anchor Vertical anchor point
  # @attr [String] h_alignment Horizontal alignment
  # @attr [String] v_alignment Vertical alignment
  # @attr [String] wrap Text wrapping style
  # @attr [Boolean] lock_anchor Lock anchor position
  class TextFrame < Lutaml::Model::Serializable
    # Anchor types
    ANCHOR_TYPES = %w[margin page text column character].freeze

    # Alignment options
    H_ALIGNMENTS = %w[left center right inside outside].freeze
    V_ALIGNMENTS = %w[top center bottom inside outside].freeze

    # Size rules
    SIZE_RULES = %w[auto atLeast exact].freeze

    # Wrap types
    WRAP_TYPES = %w[around none through tight].freeze

    attribute :width, :integer
    attribute :height, :integer
    attribute :h_rule, :string, default: -> { 'auto' }
    attribute :w_rule, :string, default: -> { 'auto' }
    attribute :x, :integer
    attribute :y, :integer
    attribute :h_anchor, :string, default: -> { 'text' }
    attribute :v_anchor, :string, default: -> { 'text' }
    attribute :h_alignment, :string
    attribute :v_alignment, :string
    attribute :wrap, :string, default: -> { 'around' }
    attribute :lock_anchor, :boolean, default: -> { false }

    def initialize(**attributes)
      super
      validate_anchors
      validate_alignments
      validate_rules
      validate_wrap
    end

    # Create absolutely positioned frame
    #
    # @param width [Integer] Frame width
    # @param height [Integer] Frame height
    # @param x [Integer] Horizontal position
    # @param y [Integer] Vertical position
    # @param options [Hash] Additional options
    # @return [TextFrame] New instance
    def self.absolute(width:, height:, x:, y:, **options)
      new(
        width: width,
        height: height,
        x: x,
        y: y,
        h_rule: 'exact',
        w_rule: 'exact',
        **options
      )
    end

    # Create aligned frame
    #
    # @param width [Integer] Frame width
    # @param h_alignment [String] Horizontal alignment
    # @param v_alignment [String] Vertical alignment
    # @param options [Hash] Additional options
    # @return [TextFrame] New instance
    def self.aligned(width:, h_alignment:, v_alignment:, **options)
      new(
        width: width,
        h_alignment: h_alignment,
        v_alignment: v_alignment,
        h_rule: 'exact',
        **options
      )
    end

    # Check if frame uses absolute positioning
    #
    # @return [Boolean] true if has x,y coordinates
    def absolute_position?
      !x.nil? && !y.nil?
    end

    # Check if frame uses alignment positioning
    #
    # @return [Boolean] true if has alignments
    def aligned_position?
      !h_alignment.nil? || !v_alignment.nil?
    end

    private

    def validate_anchors
      if h_anchor && !ANCHOR_TYPES.include?(h_anchor)
        raise ArgumentError, "Invalid h_anchor: #{h_anchor}. Must be one of: #{ANCHOR_TYPES.join(', ')}"
      end
      if v_anchor && !ANCHOR_TYPES.include?(v_anchor)
        raise ArgumentError, "Invalid v_anchor: #{v_anchor}. Must be one of: #{ANCHOR_TYPES.join(', ')}"
      end
    end

    def validate_alignments
      if h_alignment && !H_ALIGNMENTS.include?(h_alignment)
        raise ArgumentError, "Invalid h_alignment: #{h_alignment}. Must be one of: #{H_ALIGNMENTS.join(', ')}"
      end
      if v_alignment && !V_ALIGNMENTS.include?(v_alignment)
        raise ArgumentError, "Invalid v_alignment: #{v_alignment}. Must be one of: #{V_ALIGNMENTS.join(', ')}"
      end
    end

    def validate_rules
      if h_rule && !SIZE_RULES.include?(h_rule)
        raise ArgumentError, "Invalid h_rule: #{h_rule}. Must be one of: #{SIZE_RULES.join(', ')}"
      end
      if w_rule && !SIZE_RULES.include?(w_rule)
        raise ArgumentError, "Invalid w_rule: #{w_rule}. Must be one of: #{SIZE_RULES.join(', ')}"
      end
    end

    def validate_wrap
      return unless wrap && !WRAP_TYPES.include?(wrap)

      raise ArgumentError, "Invalid wrap: #{wrap}. Must be one of: #{WRAP_TYPES.join(', ')}"
    end
  end
end