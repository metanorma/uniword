# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'sheet'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :name
            map_attribute 'true', to: :sheet_id
            map_attribute 'true', to: :id
            map_attribute 'true', to: :state
          end
      end
    end
  end
end
