# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Collection of worksheet definitions
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:sheets>
      class Sheets < Lutaml::Model::Serializable
          attribute :sheet_entries, Sheet, collection: true, default: -> { [] }

          xml do
            root 'sheets'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'sheet', to: :sheet_entries, render_nil: false
          end
      end
    end
  end
end
