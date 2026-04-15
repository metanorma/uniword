# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Color filter criteria
    #
    # Element: <colorFilter>
    class ColorFilter < Lutaml::Model::Serializable
      attribute :dxf_id, :string
      attribute :cell_color, :string

      xml do
        element "colorFilter"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute "dxfId", to: :dxf_id, render_nil: false
        map_attribute "cellColor", to: :cell_color, render_nil: false
      end
    end
  end
end
