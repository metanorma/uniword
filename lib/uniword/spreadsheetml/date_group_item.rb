# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Date grouping in filters
    #
    # Element: <dateGroupItem>
    class DateGroupItem < Lutaml::Model::Serializable
      attribute :year, :integer
      attribute :month, :integer
      attribute :day, :integer
      attribute :hour, :integer
      attribute :minute, :integer
      attribute :second, :integer
      attribute :date_time_grouping, :string

      xml do
        element 'dateGroupItem'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'year', to: :year
        map_attribute 'month', to: :month, render_nil: false
        map_attribute 'day', to: :day, render_nil: false
        map_attribute 'hour', to: :hour, render_nil: false
        map_attribute 'minute', to: :minute, render_nil: false
        map_attribute 'second', to: :second, render_nil: false
        map_attribute 'dateTimeGrouping', to: :date_time_grouping
      end
    end
  end
end
