# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Table column definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:tableColumn>
      class TableColumn < Lutaml::Model::Serializable
          attribute :id, Integer
          attribute :name, String

          xml do
            root 'tableColumn'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :name
          end
      end
    end
  end
end
