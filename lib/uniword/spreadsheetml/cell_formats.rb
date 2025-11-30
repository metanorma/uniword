# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Cell formats collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:cellXfs>
      class CellFormats < Lutaml::Model::Serializable
          attribute :count, Integer
          attribute :formats, CellFormat, collection: true, default: -> { [] }

          xml do
            element 'cellXfs'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML
            mixed_content

            map_attribute 'count', to: :count
            map_element 'xf', to: :formats, render_nil: false
          end
      end
    end
end
