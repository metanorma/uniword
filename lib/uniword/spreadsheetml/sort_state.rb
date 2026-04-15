# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Sort state for auto filter
    #
    # Element: <sortState>
    class SortState < Lutaml::Model::Serializable
      attribute :ref, :string
      attribute :sort_condition, SortCondition, collection: true, initialize_empty: true

      xml do
        element "sortState"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "ref", to: :ref, render_nil: false
        map_element "sortCondition", to: :sort_condition, render_nil: false
      end
    end
  end
end
