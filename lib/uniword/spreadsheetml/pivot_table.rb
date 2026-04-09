# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Pivot table reference
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:pivotTable>
    class PivotTable < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :cache_id, :integer

      xml do
        element 'pivotTable'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'name', to: :name
        map_attribute 'cache-id', to: :cache_id
      end
    end
  end
end
