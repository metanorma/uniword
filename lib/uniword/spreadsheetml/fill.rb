# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Fill definition
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:fill>
    class Fill < Lutaml::Model::Serializable
      attribute :pattern_fill, PatternFill

      xml do
        element "fill"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element "patternFill", to: :pattern_fill, render_nil: false
      end
    end
  end
end
