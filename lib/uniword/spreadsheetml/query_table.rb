# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Query table definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:queryTable>
      class QueryTable < Lutaml::Model::Serializable
          attribute :name, String
          attribute :connection_id, Integer

          xml do
            element 'queryTable'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML

            map_attribute 'name', to: :name
            map_attribute 'connection-id', to: :connection_id
          end
      end
    end
end
