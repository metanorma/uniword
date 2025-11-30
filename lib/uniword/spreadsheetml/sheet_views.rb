# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Sheet views collection
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:sheetViews>
    class SheetViews < Lutaml::Model::Serializable
      attribute :views, SheetView, collection: true, default: -> { [] }

      xml do
        element 'sheetViews'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element 'sheetView', to: :views, render_nil: false
      end
    end
  end
end
