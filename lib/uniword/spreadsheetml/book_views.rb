# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Workbook views collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:bookViews>
      class BookViews < Lutaml::Model::Serializable
          attribute :views, WorkbookView, collection: true, default: -> { [] }

          xml do
            element 'bookViews'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML
            mixed_content

            map_element 'workbookView', to: :views, render_nil: false
          end
      end
    end
end
