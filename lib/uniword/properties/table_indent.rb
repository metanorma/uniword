# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Table indent property
    #
    # Represents w:tblInd element for table indentation
    # Element: <w:tblInd w:w="..." w:type="dxa"/>
    class TableIndent < Lutaml::Model::Serializable
      attribute :value, :integer
      attribute :type, :string

      xml do
        element "tblInd"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "w", to: :value
        map_attribute "type", to: :type
      end
    end
  end
end
