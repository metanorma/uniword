# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Filters container for filter column
    #
    # Element: <filters>
    class Filters < Lutaml::Model::Serializable
      attribute :blank, :string
      attribute :calendar_type, :string
      attribute :filter, Filter, collection: true, initialize_empty: true
      attribute :date_group_item, DateGroupItem, collection: true, initialize_empty: true

      xml do
        element 'filters'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'blank', to: :blank, render_nil: false
        map_attribute 'calendarType', to: :calendar_type, render_nil: false
        map_element 'filter', to: :filter, render_nil: false
        map_element 'dateGroupItem', to: :date_group_item, render_nil: false
      end
    end
  end
end
