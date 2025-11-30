# frozen_string_literal: true

require 'lutaml/model'

module Uniword
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
        element 'sheetProtection'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'password', to: :password
        map_attribute 'sheet', to: :sheet
        map_attribute 'objects', to: :objects
        map_attribute 'scenarios', to: :scenarios
      end
    end
  end
end
