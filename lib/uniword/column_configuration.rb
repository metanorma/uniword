# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  # Represents a single column in a multi-column layout
  #
  # @attr [Integer] width Column width in twips
  # @attr [Integer] space Space after this column in twips
  class Column < Lutaml::Model::Serializable
    attribute :width, :integer
    attribute :space, :integer
  end

  # Represents column configuration for a section
  #
  # Columns allow text to flow in newspaper-style multi-column layouts.
  #
  # @example Two equal columns
  #   cols = ColumnConfiguration.new(count: 2, equal_width: true, space: 720)
  #
  # @example Three unequal columns
  #   cols = ColumnConfiguration.new(count: 3, equal_width: false)
  #   cols.columns = [
  #     Column.new(width: 2880, space: 360),
  #     Column.new(width: 4320, space: 360),
  #     Column.new(width: 2880, space: 0)
  #   ]
  #
  # @attr [Integer] count Number of columns
  # @attr [Boolean] equal_width Whether all columns have equal width
  # @attr [Integer] space Default space between columns (for equal width)
  # @attr [Boolean] separator Whether to show vertical separator line
  # @attr [Array<Column>] columns Individual column definitions (for unequal)
  class ColumnConfiguration < Lutaml::Model::Serializable
    attribute :count, :integer, default: -> { 1 }
    attribute :equal_width, :boolean, default: -> { true }
    attribute :space, :integer, default: -> { 720 } # 0.5 inch
    attribute :separator, :boolean, default: -> { false }
    attribute :columns, Column, collection: true, initialize_empty: true

    def initialize(**attributes)
      super
      validate_count
      validate_columns
    end

    # Create equal-width columns configuration
    #
    # @param count [Integer] Number of columns
    # @param space [Integer] Space between columns in twips
    # @param separator [Boolean] Show separator line
    # @return [ColumnConfiguration] New instance
    def self.equal(count, space: 720, separator: false)
      new(
        count: count,
        equal_width: true,
        space: space,
        separator: separator
      )
    end

    # Create two-column layout
    #
    # @param space [Integer] Space between columns
    # @param separator [Boolean] Show separator line
    # @return [ColumnConfiguration] New instance
    def self.two_columns(space: 720, separator: false)
      equal(2, space: space, separator: separator)
    end

    # Create three-column layout
    #
    # @param space [Integer] Space between columns
    # @param separator [Boolean] Show separator line
    # @return [ColumnConfiguration] New instance
    def self.three_columns(space: 720, separator: false)
      equal(3, space: space, separator: separator)
    end

    # Check if using single column (no multi-column layout)
    #
    # @return [Boolean] true if single column
    def single_column?
      count == 1
    end

    # Check if using custom column widths
    #
    # @return [Boolean] true if custom widths
    def custom_widths?
      !equal_width && !columns.empty?
    end

    private

    def validate_count
      return unless count && count < 1

      raise ArgumentError, "Column count must be at least 1, got: #{count}"
    end

    def validate_columns
      return if equal_width || columns.empty?
      return if columns.size == count

      raise ArgumentError,
            "Number of column definitions (#{columns.size}) must match count (#{count})"
    end
  end
end
