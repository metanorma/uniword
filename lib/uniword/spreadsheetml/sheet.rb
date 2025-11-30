# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Worksheet reference in workbook
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:sheet>
      class Sheet < Lutaml::Model::Serializable
          attribute :name, String
          attribute :sheet_id, Integer
          attribute :id, String
          attribute :state, String

          xml do
            element 'sheet'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML

            map_attribute 'name', to: :name
            map_attribute 'sheet-id', to: :sheet_id
            map_attribute 'id', to: :id
            map_attribute 'state', to: :state
          end
      end
    end
end
