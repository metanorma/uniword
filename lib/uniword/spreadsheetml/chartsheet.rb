# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Chart sheet definition
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:chartsheet>
    class Chartsheet < Lutaml::Model::Serializable
      attribute :sheet_views, :string
      attribute :drawing, Drawing

      xml do
        element "chartsheet"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element "sheetViews", to: :sheet_views, render_nil: false
        map_element "drawing", to: :drawing, render_nil: false
      end
    end
  end
end
