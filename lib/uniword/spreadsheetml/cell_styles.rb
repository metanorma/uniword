# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Cell Styles
    #
    # Complex type for a collection of named cell styles.
    class CellStyles < Lutaml::Model::Serializable
      attribute :count, :integer
      attribute :cell_style, CellStyle, collection: true, initialize_empty: true

      xml do
        element "cellStyles"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "count", to: :count, render_nil: false
        map_element "cellStyle", to: :cell_style, render_nil: false
      end
    end
  end
end
