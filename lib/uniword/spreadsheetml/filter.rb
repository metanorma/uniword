# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Individual filter value
    #
    # Element: <filter>
    class Filter < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "filter"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "val", to: :val
      end
    end
  end
end
