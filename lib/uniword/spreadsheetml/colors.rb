# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Colors
    #
    # Complex type for custom colors in styles.
    class Colors < Lutaml::Model::Serializable
      attribute :color, Color, collection: true, initialize_empty: true

      xml do
        element "colors"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_element "color", to: :color, render_nil: false
      end
    end
  end
end
