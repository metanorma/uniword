# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Table definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:table>
      class Table < Lutaml::Model::Serializable
          attribute :id, Integer
          attribute :name, String
          attribute :display_name, String
          attribute :ref, String
          attribute :table_columns, TableColumns
          attribute :table_style_info, TableStyleInfo
          attribute :auto_filter, AutoFilter

          xml do
            root 'table'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :id
            map_attribute 'true', to: :name
            map_attribute 'true', to: :display_name
            map_attribute 'true', to: :ref
            map_element 'tableColumns', to: :table_columns
            map_element 'tableStyleInfo', to: :table_style_info, render_nil: false
            map_element 'autoFilter', to: :auto_filter, render_nil: false
          end
      end
    end
  end
end
