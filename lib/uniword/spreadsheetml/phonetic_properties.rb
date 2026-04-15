# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Phonetic properties for East Asian text
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:phoneticPr>
    class PhoneticProperties < Lutaml::Model::Serializable
      attribute :font_id, :integer
      attribute :type, :string

      xml do
        element "phoneticPr"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "font-id", to: :font_id
        map_attribute "type", to: :type
      end
    end
  end
end
