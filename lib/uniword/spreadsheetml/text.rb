# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Text element
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:t>
    class Text < Lutaml::Model::Serializable
      attribute :text, :string
      attribute :space, :string

      xml do
        element "t"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_content to: :text
        map_attribute "space", to: :space
      end
    end
  end
end
