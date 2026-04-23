# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Custom filters container
    #
    # Element: <customFilters>
    class CustomFilters < Lutaml::Model::Serializable
      attribute :and, :string
      attribute :custom_filter, CustomFilter, collection: true,
                                              initialize_empty: true

      xml do
        element "customFilters"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "and", to: :and, render_nil: false
        map_element "customFilter", to: :custom_filter, render_nil: false
      end
    end
  end
end
