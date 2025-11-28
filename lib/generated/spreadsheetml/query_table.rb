# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Query table definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:queryTable>
      class QueryTable < Lutaml::Model::Serializable
          attribute :name, String
          attribute :connection_id, Integer

          xml do
            root 'queryTable'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :name
            map_attribute 'true', to: :connection_id
          end
      end
    end
  end
end
