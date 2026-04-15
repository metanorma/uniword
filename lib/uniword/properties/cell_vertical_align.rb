# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Cell vertical alignment enumeration
    #
    # Represents vertical alignment types from OOXML specification
    class CellVerticalAlignValue < Lutaml::Model::Type::String
    end

    # Table cell vertical alignment
    #
    # Represents <w:vAlign> element with alignment value.
    # Used in table cell properties to specify vertical positioning of content.
    #
    # @example Creating vertical align
    #   valign = CellVerticalAlign.new(value: 'center')
    class CellVerticalAlign < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :value, CellVerticalAlignValue # Alignment: top, center, bottom

      xml do
        element "vAlign"
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :value
      end
    end
  end
end
