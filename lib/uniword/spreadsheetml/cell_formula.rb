# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Cell formula element
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:f>
    class CellFormula < Lutaml::Model::Serializable
      attribute :t, :string
      attribute :ref, :string
      attribute :si, :integer
      attribute :text, :string

      xml do
        element "f"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "t", to: :t
        map_attribute "ref", to: :ref
        map_attribute "si", to: :si
        map_content to: :text
      end
    end
  end
end
