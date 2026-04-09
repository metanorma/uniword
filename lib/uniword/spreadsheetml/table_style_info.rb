# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Table style information
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:tableStyleInfo>
    class TableStyleInfo < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :show_first_column, :string
      attribute :show_last_column, :string
      attribute :show_row_stripes, :string
      attribute :show_column_stripes, :string

      xml do
        element 'tableStyleInfo'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'name', to: :name
        map_attribute 'show-first-column', to: :show_first_column
        map_attribute 'show-last-column', to: :show_last_column
        map_attribute 'show-row-stripes', to: :show_row_stripes
        map_attribute 'show-column-stripes', to: :show_column_stripes
      end
    end
  end
end
