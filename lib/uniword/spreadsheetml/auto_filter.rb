# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Auto filter settings
    #
    # Element: <autoFilter>
    class AutoFilter < Lutaml::Model::Serializable
      attribute :ref, :string
      attribute :filter_columns, FilterColumn, collection: true,
                                               initialize_empty: true
      attribute :sort_state, SortState

      xml do
        element "autoFilter"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "ref", to: :ref
        map_element "filterColumn", to: :filter_columns, render_nil: false
        map_element "sortState", to: :sort_state, render_nil: false
      end
    end
  end
end
