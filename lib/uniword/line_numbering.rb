# frozen_string_literal: true

require "lutaml/model"

module Uniword
  # Represents line numbering configuration for a section
  #
  # Line numbering displays line numbers in the margin of a document section.
  # It's commonly used in legal documents and academic papers.
  #
  # @example Continuous line numbering
  #   ln = LineNumbering.new(
  #     start: 1,
  #     count_by: 1,
  #     restart: 'continuous'
  #   )
  #
  # @example Line numbering restarting on each page
  #   ln = LineNumbering.new(
  #     count_by: 5,
  #     restart: 'newPage',
  #     distance: 360
  #   )
  #
  # @attr [Integer] start Starting line number
  # @attr [Integer] count_by Increment for numbering (e.g., 5 = 5, 10, 15...)
  # @attr [String] restart When to restart numbering
  # @attr [Integer] distance Distance from text in twips
  class LineNumbering < Lutaml::Model::Serializable
    # Restart options
    RESTART_OPTIONS = %w[continuous newPage newSection].freeze

    attribute :start, :integer, default: -> { 1 }
    attribute :count_by, :integer, default: -> { 1 }
    attribute :restart, :string, default: -> { "newPage" }
    attribute :distance, :integer, default: -> { 360 } # 0.25 inch

    def initialize(**attributes)
      super
      validate_restart
      validate_start
      validate_count_by
    end

    # Create continuous line numbering (never restarts)
    #
    # @param count_by [Integer] Increment
    # @param distance [Integer] Distance from text
    # @return [LineNumbering] New instance
    def self.continuous(count_by: 1, distance: 360)
      new(
        start: 1,
        count_by: count_by,
        restart: "continuous",
        distance: distance,
      )
    end

    # Create line numbering that restarts on each page
    #
    # @param count_by [Integer] Increment
    # @param distance [Integer] Distance from text
    # @return [LineNumbering] New instance
    def self.per_page(count_by: 1, distance: 360)
      new(
        start: 1,
        count_by: count_by,
        restart: "newPage",
        distance: distance,
      )
    end

    # Create line numbering that restarts on each section
    #
    # @param count_by [Integer] Increment
    # @param distance [Integer] Distance from text
    # @return [LineNumbering] New instance
    def self.per_section(count_by: 1, distance: 360)
      new(
        start: 1,
        count_by: count_by,
        restart: "newSection",
        distance: distance,
      )
    end

    # Check if numbering is continuous (never restarts)
    #
    # @return [Boolean] true if continuous
    def continuous?
      restart == "continuous"
    end

    # Check if numbering restarts on each page
    #
    # @return [Boolean] true if per page
    def per_page?
      restart == "newPage"
    end

    # Check if numbering restarts on each section
    #
    # @return [Boolean] true if per section
    def per_section?
      restart == "newSection"
    end

    private

    def validate_restart
      return unless restart && !RESTART_OPTIONS.include?(restart)

      raise ArgumentError,
            "Invalid restart option: #{restart}. Must be one of: #{RESTART_OPTIONS.join(', ')}"
    end

    def validate_start
      return unless start && start < 1

      raise ArgumentError, "Start must be at least 1, got: #{start}"
    end

    def validate_count_by
      return unless count_by && count_by < 1

      raise ArgumentError, "Count_by must be at least 1, got: #{count_by}"
    end
  end
end
