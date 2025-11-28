# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Table style information
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:tableStyleInfo>
      class TableStyleInfo < Lutaml::Model::Serializable
          attribute :name, String
          attribute :show_first_column, String
          attribute :show_last_column, String
          attribute :show_row_stripes, String
          attribute :show_column_stripes, String

          xml do
            root 'tableStyleInfo'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :name
            map_attribute 'true', to: :show_first_column
            map_attribute 'true', to: :show_last_column
            map_attribute 'true', to: :show_row_stripes
            map_attribute 'true', to: :show_column_stripes
          end
      end
    end
  end
end
