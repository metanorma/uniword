# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Sheet view settings
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:sheetView>
    class SheetView < Lutaml::Model::Serializable
      attribute :workbook_view_id, Integer
      attribute :show_grid_lines, String
      attribute :show_row_col_headers, String
      attribute :tab_selected, String
      attribute :zoom_scale, Integer

      xml do
        element 'sheetView'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'workbook-view-id', to: :workbook_view_id
        map_attribute 'show-grid-lines', to: :show_grid_lines
        map_attribute 'show-row-col-headers', to: :show_row_col_headers
        map_attribute 'tab-selected', to: :tab_selected
        map_attribute 'zoom-scale', to: :zoom_scale
      end
    end
  end
end
