# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Filter column settings
    #
    # Element: <filterColumn>
    class FilterColumn < Lutaml::Model::Serializable
      attribute :col_id, :integer
      attribute :hidden_button, :string
      attribute :show_button, :string
      attribute :filters, Filters
      attribute :top10, Top10
      attribute :custom_filters, CustomFilters
      attribute :dynamic_filter, DynamicFilter
      attribute :color_filter, ColorFilter
      attribute :icon_filter, IconFilter

      xml do
        element "filterColumn"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "colId", to: :col_id
        map_attribute "hiddenButton", to: :hidden_button, render_nil: false
        map_attribute "showButton", to: :show_button, render_nil: false
        map_element "filters", to: :filters, render_nil: false
        map_element "top10", to: :top10, render_nil: false
        map_element "customFilters", to: :custom_filters, render_nil: false
        map_element "dynamicFilter", to: :dynamic_filter, render_nil: false
        map_element "colorFilter", to: :color_filter, render_nil: false
        map_element "iconFilter", to: :icon_filter, render_nil: false
      end
    end
  end
end
