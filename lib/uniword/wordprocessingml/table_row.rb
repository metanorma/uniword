# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Table row
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:tr>
      class TableRow < Lutaml::Model::Serializable
          attribute :properties, TableRowProperties
          attribute :cells, TableCell, collection: true, default: -> { [] }

          xml do
            element 'tr'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML
            mixed_content

            map_element 'trPr', to: :properties, render_nil: false
            map_element 'tc', to: :cells, render_nil: false
          end
      end
    end
end
