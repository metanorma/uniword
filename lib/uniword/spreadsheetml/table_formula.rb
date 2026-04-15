# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Table column calculated formula
    #
    # Element: <tableFormula>
    class TableFormula < Lutaml::Model::Serializable
      attribute :array, :string
      attribute :content, :string

      xml do
        element "tableFormula"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute "array", to: :array, render_nil: false
      end
    end
  end
end
