# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Legacy drawing reference
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:legacyDrawing>
    class LegacyDrawing < Lutaml::Model::Serializable
      attribute :id, :string

      xml do
        element "legacyDrawing"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "id", to: :id
      end
    end
  end
end
