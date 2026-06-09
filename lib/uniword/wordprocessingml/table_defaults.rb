# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    # Shared table structure defaults.
    #
    # Provides canonical values for table look, grid, and cell width defaults
    # used by both builder and reconciler.
    module TableDefaults
      DEFAULT_TABLE_LOOK = Properties::TableLook.new(
        val: "04A0",
        first_row: 1,
        last_row: 0,
        first_column: 1,
        last_column: 0,
        no_h_band: 0,
        no_v_band: 1,
      ).freeze

      def self.default_table_look
        Properties::TableLook.new(
          val: DEFAULT_TABLE_LOOK.val,
          first_row: DEFAULT_TABLE_LOOK.first_row,
          last_row: DEFAULT_TABLE_LOOK.last_row,
          first_column: DEFAULT_TABLE_LOOK.first_column,
          last_column: DEFAULT_TABLE_LOOK.last_column,
          no_h_band: DEFAULT_TABLE_LOOK.no_h_band,
          no_v_band: DEFAULT_TABLE_LOOK.no_v_band,
        )
      end

      def self.fill_missing_table_look(look)
        look.val ||= DEFAULT_TABLE_LOOK.val
        look.first_row ||= DEFAULT_TABLE_LOOK.first_row
        look.last_row ||= DEFAULT_TABLE_LOOK.last_row
        look.first_column ||= DEFAULT_TABLE_LOOK.first_column
        look.last_column ||= DEFAULT_TABLE_LOOK.last_column
        look.no_h_band ||= DEFAULT_TABLE_LOOK.no_h_band
        look.no_v_band ||= DEFAULT_TABLE_LOOK.no_v_band
        look
      end
    end
  end
end
