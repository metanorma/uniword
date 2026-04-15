# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Cell data container
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:sheetData>
    class SheetData < Lutaml::Model::Serializable
      attribute :rows, Row, collection: true, initialize_empty: true

      xml do
        element "sheetData"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element "row", to: :rows, render_nil: false
      end
    end
  end
end
