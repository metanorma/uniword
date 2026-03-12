# frozen_string_literal: true

require 'lutaml/model'

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

      # Set vertical merge
      #
      # @param value [String, Integer] Vertical merge value
      # @return [self] For method chaining
      def vertical_merge=(value)
        self.v_merge = value.to_s
        self
      end

      # Get vertical merge
      #
      # @return [String, nil] Vertical merge value
      def vertical_merge
        v_merge
      end
    end
  end
end
