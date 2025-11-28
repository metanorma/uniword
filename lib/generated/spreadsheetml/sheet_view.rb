# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'sheetView'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :workbook_view_id
            map_attribute 'true', to: :show_grid_lines
            map_attribute 'true', to: :show_row_col_headers
            map_attribute 'true', to: :tab_selected
            map_attribute 'true', to: :zoom_scale
          end
      end
    end
  end
end
