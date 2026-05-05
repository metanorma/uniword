# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Table cell properties
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:tcPr>
    class TableCellProperties < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :cell_width, Uniword::Properties::CellWidth
      attribute :width, :integer # Convenience attribute for width
      attribute :borders, TableCellBorders
      attribute :shading, Uniword::Properties::Shading
      attribute :vertical_align, Uniword::Properties::CellVerticalAlign
      attribute :grid_span, ValInt
      attribute :v_merge, ValInt
      attribute :tc_mar, TableCellMargin
      attribute :cnf_style, CnfStyle
      attribute :no_wrap, NoWrap
      attribute :hide_mark, HideMark
      attribute :text_direction, TextDirection

      xml do
        element "tcPr"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element "tcW", to: :cell_width, render_nil: false
        map_element "tcBorders", to: :borders, render_nil: false
        map_element "shd", to: :shading, render_nil: false
        map_element "vAlign", to: :vertical_align, render_nil: false
        map_element "gridSpan", to: :grid_span, render_nil: false
        map_element "vMerge", to: :v_merge, render_nil: false
        map_element "tcMar", to: :tc_mar, render_nil: false
        map_element "cnfStyle", to: :cnf_style, render_nil: false
        map_element "noWrap", to: :no_wrap, render_nil: false
        map_element "hideMark", to: :hide_mark, render_nil: false
        map_element "textDirection", to: :text_direction,
                                     render_nil: false
      end
    end
  end
end
