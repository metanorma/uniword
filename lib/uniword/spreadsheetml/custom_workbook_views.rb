# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Custom workbook views
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:customWorkbookViews>
    class CustomWorkbookViews < Lutaml::Model::Serializable
      attribute :views, :string, collection: true, default: -> { [] }

      xml do
        element 'customWorkbookViews'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element 'customWorkbookView', to: :views, render_nil: false
      end
    end
  end
end
