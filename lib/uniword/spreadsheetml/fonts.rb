# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Font collection
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:fonts>
    class Fonts < Lutaml::Model::Serializable
      attribute :count, :integer
      attribute :font_entries, Font, collection: true, initialize_empty: true

      xml do
        element "fonts"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute "count", to: :count
        map_element "font", to: :font_entries, render_nil: false
      end
    end
  end
end
