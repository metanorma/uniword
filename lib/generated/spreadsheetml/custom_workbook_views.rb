# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Custom workbook views
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:customWorkbookViews>
      class CustomWorkbookViews < Lutaml::Model::Serializable
          attribute :views, String, collection: true, default: -> { [] }

          xml do
            root 'customWorkbookViews'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'customWorkbookView', to: :views, render_nil: false
          end
      end
    end
  end
end
