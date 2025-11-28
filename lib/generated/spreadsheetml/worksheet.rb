# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Worksheet root element
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:worksheet>
      class Worksheet < Lutaml::Model::Serializable
          attribute :dimension, Dimension
          attribute :sheet_views, SheetViews
          attribute :cols, Cols
          attribute :sheet_data, SheetData
          attribute :merge_cells, MergeCells
          attribute :hyperlinks, Hyperlinks

          xml do
            root 'worksheet'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'dimension', to: :dimension, render_nil: false
            map_element 'sheetViews', to: :sheet_views, render_nil: false
            map_element 'cols', to: :cols, render_nil: false
            map_element 'sheetData', to: :sheet_data
            map_element 'mergeCells', to: :merge_cells, render_nil: false
            map_element 'hyperlinks', to: :hyperlinks, render_nil: false
          end
      end
    end
  end
end
