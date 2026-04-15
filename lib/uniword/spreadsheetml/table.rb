# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Table definition
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:table>
    class Table < Lutaml::Model::Serializable
      attribute :id, :integer
      attribute :name, :string
      attribute :display_name, :string
      attribute :ref, :string
      attribute :table_columns, TableColumns
      attribute :table_style_info, TableStyleInfo
      attribute :auto_filter, AutoFilter

      xml do
        element "table"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute "id", to: :id
        map_attribute "name", to: :name
        map_attribute "display-name", to: :display_name
        map_attribute "ref", to: :ref
        map_element "tableColumns", to: :table_columns
        map_element "tableStyleInfo", to: :table_style_info, render_nil: false
        map_element "autoFilter", to: :auto_filter, render_nil: false
      end
    end
  end
end
