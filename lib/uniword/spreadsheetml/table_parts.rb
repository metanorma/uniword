# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Table Parts
    #
    # Complex type for a collection of table references in a worksheet.
    class TableParts < Lutaml::Model::Serializable
      attribute :count, :integer
      attribute :table_part, :string, collection: true, initialize_empty: true

      xml do
        element "tableParts"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "count", to: :count, render_nil: false
        map_element "tablePart", to: :table_part, render_nil: false
      end
    end
  end
end
