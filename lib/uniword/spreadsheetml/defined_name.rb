# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Named range definition
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:definedName>
    class DefinedName < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :comment, :string
      attribute :local_sheet_id, :integer
      attribute :hidden, :string

      xml do
        element "definedName"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "name", to: :name
        map_attribute "comment", to: :comment
        map_attribute "local-sheet-id", to: :local_sheet_id
        map_attribute "hidden", to: :hidden
      end
    end
  end
end
