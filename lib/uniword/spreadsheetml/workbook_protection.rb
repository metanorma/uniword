# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Workbook protection settings
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:workbookProtection>
      class WorkbookProtection < Lutaml::Model::Serializable
          attribute :lock_structure, String
          attribute :lock_windows, String

          xml do
            element 'workbookProtection'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML

            map_attribute 'lock-structure', to: :lock_structure
            map_attribute 'lock-windows', to: :lock_windows
          end
      end
    end
end
