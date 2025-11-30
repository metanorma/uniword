# frozen_string_literal: true

require 'lutaml/model'

module Uniword
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
            element 'pivotTableDefinition'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML

            map_attribute 'name', to: :name
            map_attribute 'cache-id', to: :cache_id
            map_attribute 'data-on-rows', to: :data_on_rows
          end
      end
    end
end
