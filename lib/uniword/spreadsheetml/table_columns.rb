# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Table columns collection
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:tableColumns>
    class TableColumns < Lutaml::Model::Serializable
      attribute :count, Integer
      attribute :columns, TableColumn, collection: true, default: -> { [] }

      xml do
        element 'tableColumns'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute 'count', to: :count
        map_element 'tableColumn', to: :columns, render_nil: false
      end
    end
  end
end
