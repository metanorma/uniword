# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Individual cell
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:c>
    class Cell < Lutaml::Model::Serializable
      attribute :r, :string
      attribute :s, :integer
      attribute :t, :string
      attribute :v, CellValue
      attribute :f, CellFormula

      xml do
        element "c"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute "r", to: :r
        map_attribute "s", to: :s
        map_attribute "t", to: :t
        map_element "v", to: :v, render_nil: false
        map_element "f", to: :f, render_nil: false
      end
    end
  end
end
