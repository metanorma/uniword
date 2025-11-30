# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Table border definitions
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:tblBorders>
      class TableBorders < Lutaml::Model::Serializable
          attribute :top, Border
          attribute :bottom, Border
          attribute :left, Border
          attribute :right, Border
          attribute :inside_h, Border
          attribute :inside_v, Border

          xml do
            element 'tblBorders'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML
            mixed_content

            map_element 'top', to: :top, render_nil: false
            map_element 'bottom', to: :bottom, render_nil: false
            map_element 'left', to: :left, render_nil: false
            map_element 'right', to: :right, render_nil: false
            map_element 'insideH', to: :inside_h, render_nil: false
            map_element 'insideV', to: :inside_v, render_nil: false
          end
      end
    end
end
