# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Filter column settings
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:filterColumn>
      class FilterColumn < Lutaml::Model::Serializable
          attribute :col_id, Integer

          xml do
            root 'filterColumn'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :col_id
          end
      end
    end
  end
end
