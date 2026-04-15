# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Top 10 filter
    #
    # Element: <top10>
    class Top10 < Lutaml::Model::Serializable
      attribute :top, :string
      attribute :percent, :string
      attribute :val, :float
      attribute :filter_val, :float

      xml do
        element "top10"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "top", to: :top, render_nil: false
        map_attribute "percent", to: :percent, render_nil: false
        map_attribute "val", to: :val
        map_attribute "filterVal", to: :filter_val, render_nil: false
      end
    end
  end
end
