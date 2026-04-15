# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Namespaced custom type for highlight value
    class HighlightValue < Lutaml::Model::Type::String
    end

    # Text highlight element
    #
    # Represents <w:highlight w:val="..."/> where value is:
    # - yellow, green, cyan, magenta, blue, red, darkBlue, darkCyan,
    #   darkGreen, darkMagenta, darkRed, darkYellow, darkGray,
    #   lightGray, black, white, none
    class Highlight < Lutaml::Model::Serializable
      attribute :value, HighlightValue

      xml do
        element "highlight"
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :value
      end
    end
  end
end
