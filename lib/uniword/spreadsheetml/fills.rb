# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Fill collection
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:fills>
    class Fills < Lutaml::Model::Serializable
      attribute :count, :integer
      attribute :fill_entries, Fill, collection: true, initialize_empty: true

      xml do
        element "fills"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute "count", to: :count
        map_element "fill", to: :fill_entries, render_nil: false
      end
    end
  end
end
