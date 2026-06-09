# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    # Shared page layout defaults.
    #
    # Provides canonical values for page size, margins, columns, and docGrid
    # used by both builder and reconciler.
    module PageDefaults
      LETTER_WIDTH  = 12_240
      LETTER_HEIGHT = 15_840

      DEFAULT_MARGINS = {
        top: 1440, right: 1440, bottom: 1440, left: 1440,
        header: 720, footer: 720, gutter: 0,
      }.freeze

      DEFAULT_COL_SPACE = 720
      DEFAULT_LINE_PITCH = 360

      def self.default_page_size
        Wordprocessingml::PageSize.new(width: LETTER_WIDTH,
                                       height: LETTER_HEIGHT)
      end

      def self.default_page_margins
        Wordprocessingml::PageMargins.new(**DEFAULT_MARGINS)
      end

      def self.default_columns
        Wordprocessingml::Columns.new(space: DEFAULT_COL_SPACE)
      end

      def self.default_doc_grid
        Wordprocessingml::DocGrid.new(line_pitch: DEFAULT_LINE_PITCH)
      end
    end
  end
end
