# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Cell data container
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:sheetData>
      class SheetData < Lutaml::Model::Serializable
          attribute :rows, Row, collection: true, default: -> { [] }

          xml do
            root 'sheetData'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'row', to: :rows, render_nil: false
          end
      end
    end
  end
end
