# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Collection of worksheet definitions
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:sheets>
      class Sheets < Lutaml::Model::Serializable
          attribute :sheet_entries, Sheet, collection: true, default: -> { [] }

          xml do
            element 'sheets'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML
            mixed_content

            map_element 'sheet', to: :sheet_entries, render_nil: false
          end
      end
    end
end
