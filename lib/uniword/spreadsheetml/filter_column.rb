# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Filter column settings
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:filterColumn>
      class FilterColumn < Lutaml::Model::Serializable
          attribute :col_id, Integer

          xml do
            element 'filterColumn'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML

            map_attribute 'col-id', to: :col_id
          end
      end
    end
end
