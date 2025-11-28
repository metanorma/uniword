# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Workbook views collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:bookViews>
      class BookViews < Lutaml::Model::Serializable
          attribute :views, WorkbookView, collection: true, default: -> { [] }

          xml do
            root 'bookViews'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'workbookView', to: :views, render_nil: false
          end
      end
    end
  end
end
