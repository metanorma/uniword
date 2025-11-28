# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Table structure
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:tbl>
      class Table < Lutaml::Model::Serializable
          attribute :properties, TableProperties
          attribute :grid, TableGrid
          attribute :rows, TableRow, collection: true, default: -> { [] }

          xml do
            root 'tbl'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'tblPr', to: :properties, render_nil: false
            map_element 'tblGrid', to: :grid, render_nil: false
            map_element 'tr', to: :rows, render_nil: false
          end
      end
    end
  end
end
