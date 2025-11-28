# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Table grid column definitions
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:tblGrid>
      class TableGrid < Lutaml::Model::Serializable
          attribute :columns, GridCol, collection: true, default: -> { [] }

          xml do
            root 'tblGrid'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'gridCol', to: :columns, render_nil: false
          end
      end
    end
  end
end
