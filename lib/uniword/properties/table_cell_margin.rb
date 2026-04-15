# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Table cell margin specification
    # Represents margins for all four sides of a table cell
    # Reference XML:
    # <w:tblCellMar>
    #   <w:top w="0" type="dxa"/>
    #   <w:left w="108" type="dxa"/>
    #   <w:bottom w="0" type="dxa"/>
    #   <w:right w="108" type="dxa"/>
    # </w:tblCellMar>
    class TableCellMargin < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :top, Margin
      attribute :left, Margin
      attribute :bottom, Margin
      attribute :right, Margin

      xml do
        element "tblCellMar"
        namespace Ooxml::Namespaces::WordProcessingML
        map_element "top", to: :top, render_nil: false
        map_element "left", to: :left, render_nil: false
        map_element "bottom", to: :bottom, render_nil: false
        map_element "right", to: :right, render_nil: false
      end
    end
  end
end
