# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Pivot table reference
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:pivotTable>
      class PivotTable < Lutaml::Model::Serializable
          attribute :name, String
          attribute :cache_id, Integer

          xml do
            root 'pivotTable'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :name
            map_attribute 'true', to: :cache_id
          end
      end
    end
  end
end
