# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Pivot table definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:pivotTableDefinition>
      class PivotTableDefinition < Lutaml::Model::Serializable
          attribute :name, String
          attribute :cache_id, Integer
          attribute :data_on_rows, String

          xml do
            root 'pivotTableDefinition'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :name
            map_attribute 'true', to: :cache_id
            map_attribute 'true', to: :data_on_rows
          end
      end
    end
  end
end
