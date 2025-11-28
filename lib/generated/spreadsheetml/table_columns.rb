# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Table columns collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:tableColumns>
      class TableColumns < Lutaml::Model::Serializable
          attribute :count, Integer
          attribute :columns, TableColumn, collection: true, default: -> { [] }

          xml do
            root 'tableColumns'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :count
            map_element 'tableColumn', to: :columns, render_nil: false
          end
      end
    end
  end
end
