# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Workbook protection settings
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:workbookProtection>
      class WorkbookProtection < Lutaml::Model::Serializable
          attribute :lock_structure, String
          attribute :lock_windows, String

          xml do
            root 'workbookProtection'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :lock_structure
            map_attribute 'true', to: :lock_windows
          end
      end
    end
  end
end
