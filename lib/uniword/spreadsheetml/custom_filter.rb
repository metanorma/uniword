# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Single custom filter criterion
    #
    # Element: <customFilter>
    class CustomFilter < Lutaml::Model::Serializable
      attribute :operator, :string
      attribute :val, :string

      xml do
        element "customFilter"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "operator", to: :operator, render_nil: false
        map_attribute "val", to: :val
      end
    end
  end
end
