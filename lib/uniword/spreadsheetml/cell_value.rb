# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Cell value element
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:v>
    class CellValue < Lutaml::Model::Serializable
      attribute :text, :string

      xml do
        element 'v'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_element '', to: :text, render_nil: false
      end
    end
  end
end
