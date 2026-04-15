# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Spreadsheet row
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:row>
    class Row < Lutaml::Model::Serializable
      attribute :r, :integer
      attribute :spans, :string
      attribute :ht, :string
      attribute :custom_height, :string
      attribute :hidden, :string
      attribute :cells, Cell, collection: true, initialize_empty: true

      xml do
        element "row"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute "r", to: :r
        map_attribute "spans", to: :spans
        map_attribute "ht", to: :ht
        map_attribute "custom-height", to: :custom_height
        map_attribute "hidden", to: :hidden
        map_element "c", to: :cells, render_nil: false
      end
    end
  end
end
