# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Table layout property
    #
    # Represents w:tblLayout element in table properties.
    # Controls whether table columns auto-fit or use fixed widths.
    #
    # Element: <w:tblLayout w:type="autofit"/> or <w:tblLayout w:type="fixed"/>
    class TableLayout < Lutaml::Model::Serializable
      attribute :type, :string

      xml do
        element "tblLayout"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "type", to: :type
      end
    end
  end
end
