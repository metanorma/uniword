# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Sheet protection settings
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:sheetProtection>
      class SheetProtection < Lutaml::Model::Serializable
          attribute :password, String
          attribute :sheet, String
          attribute :objects, String
          attribute :scenarios, String

          xml do
            root 'sheetProtection'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :password
            map_attribute 'true', to: :sheet
            map_attribute 'true', to: :objects
            map_attribute 'true', to: :scenarios
          end
      end
    end
  end
end
