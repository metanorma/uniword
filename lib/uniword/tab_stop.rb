# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  # Represents a tab stop in a paragraph
  #
  # Tab stops control where the cursor moves when the Tab key is pressed.
  # They can have different alignments and leader characters.
  #
  # @example Create a tab stop
  #   tab = TabStop.new(position: 720, alignment: 'left', leader: 'dot')
  #
  # @attr [Integer] position Position in twips from left margin
  # @attr [String] alignment Alignment type (left, center, right, decimal, bar)
  # @attr [String] leader Leader character (none, dot, hyphen, underscore, heavy)
  class TabStop < Lutaml::Model::Serializable
    # Alignment options
    ALIGNMENTS = %w[left center right decimal bar num].freeze

    # Leader options
    LEADERS = %w[none dot hyphen underscore heavy middleDot].freeze

    attribute :position, :integer
    attribute :alignment, :string, default: -> { 'left' }
    attribute :leader, :string, default: -> { 'none' }

    def initialize(**attributes)
      super
      validate_alignment
      validate_leader
    end

    # Create a left-aligned tab stop
    #
    # @param position [Integer] Position in twips
    # @param leader [String] Leader character
    # @return [TabStop] New instance
    def self.left(position, leader: 'none')
      new(position: position, alignment: 'left', leader: leader)
    end

    # Create a center-aligned tab stop
    #
    # @param position [Integer] Position in twips
    # @param leader [String] Leader character
    # @return [TabStop] New instance
    def self.center(position, leader: 'none')
      new(position: position, alignment: 'center', leader: leader)
    end

    # Create a right-aligned tab stop
    #
    # @param position [Integer] Position in twips
    # @param leader [String] Leader character
    # @return [TabStop] New instance
    def self.right(position, leader: 'none')
      new(position: position, alignment: 'right', leader: leader)
    end

    # Create a decimal-aligned tab stop (for numbers)
    #
    # @param position [Integer] Position in twips
    # @param leader [String] Leader character
    # @return [TabStop] New instance
    def self.decimal(position, leader: 'none')
      new(position: position, alignment: 'decimal', leader: leader)
    end

    private

    def validate_alignment
      return unless alignment && !ALIGNMENTS.include?(alignment)

      raise ArgumentError,
            "Invalid alignment: #{alignment}. Must be one of: #{ALIGNMENTS.join(', ')}"
    end

    def validate_leader
      return unless leader && !LEADERS.include?(leader)

      raise ArgumentError, "Invalid leader: #{leader}. Must be one of: #{LEADERS.join(', ')}"
    end
  end
end
