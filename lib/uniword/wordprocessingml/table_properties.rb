# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Table formatting properties
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:tblPr>
      class TableProperties < Lutaml::Model::Serializable
          attribute :style, :string
          attribute :width, :integer
          attribute :width_type, :string
          attribute :alignment, :string
          attribute :borders, TableBorders
          attribute :cell_spacing, :integer
          attribute :indent, :integer
          attribute :look, :string

          xml do
            element 'tblPr'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML
            mixed_content

            map_attribute 'val', to: :style
            map_attribute 'w', to: :width
            map_attribute 'type', to: :width_type
            map_attribute 'val', to: :alignment
            map_element 'tblBorders', to: :borders, render_nil: false
            map_attribute 'w', to: :cell_spacing
            map_attribute 'w', to: :indent
            map_attribute 'val', to: :look
          end
      end
    end
end
