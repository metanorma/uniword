# frozen_string_literal: true

require 'lutaml/model'
require_relative '../properties/cell_width'
require_relative '../properties/cell_vertical_align'
require_relative '../properties/shading'

module Uniword
  module Wordprocessingml
    # Table cell properties
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:tcPr>
    class TableCellProperties < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :cell_width, Uniword::Properties::CellWidth
      attribute :borders, TableCellBorders
      attribute :shading, Uniword::Properties::Shading
      attribute :vertical_align, Uniword::Properties::CellVerticalAlign
      attribute :grid_span, :integer
      attribute :v_merge, :string

      xml do
        root 'tcPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'tcW', to: :cell_width, render_nil: false
        map_element 'tcBorders', to: :borders, render_nil: false
        map_element 'shd', to: :shading, render_nil: false
        map_element 'vAlign', to: :vertical_align, render_nil: false
        map_element 'gridSpan', to: :grid_span, render_nil: false
        map_element 'vMerge', to: :v_merge, render_nil: false
      end
    end
  end
end
