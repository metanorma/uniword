# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Table cell borders
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:tcBorders>
      class TableCellBorders < Lutaml::Model::Serializable
          attribute :top, Border
          attribute :bottom, Border
          attribute :left, Border
          attribute :right, Border

          xml do
            element 'tcBorders'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML
            mixed_content

            map_element 'top', to: :top, render_nil: false
            map_element 'bottom', to: :bottom, render_nil: false
            map_element 'left', to: :left, render_nil: false
            map_element 'right', to: :right, render_nil: false
          end
      end
    end
end
