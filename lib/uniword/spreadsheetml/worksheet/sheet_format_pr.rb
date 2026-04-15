# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    class Worksheet < Lutaml::Model::Serializable
      # Sheet Format Properties
      #
      # Complex type for worksheet format properties.
      class SheetFormatPr < Lutaml::Model::Serializable
        attribute :base_col_width, :integer
        attribute :default_row_height, :integer
        attribute :dy_designer, :integer
        attribute :out_line_level_row, :integer
        attribute :out_line_level_col, :integer
        attribute :cached_col_band, :integer
        attribute :cached_row_band, :integer

        xml do
          element "sheetFormatPr"
          namespace Uniword::Ooxml::Namespaces::SpreadsheetML

          map_attribute "baseColWidth", to: :base_col_width, render_nil: false
          map_attribute "defaultRowHeight", to: :default_row_height, render_nil: false
          map_attribute "dyDesiner", to: :dy_designer, render_nil: false
          map_attribute "outLineLevelRow", to: :out_line_level_row, render_nil: false
          map_attribute "outLineLevelCol", to: :out_line_level_col, render_nil: false
          map_attribute "cachedColBand", to: :cached_col_band, render_nil: false
          map_attribute "cachedRowBand", to: :cached_row_band, render_nil: false
        end
      end
    end
  end
end
