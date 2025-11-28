# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Cell value element
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:v>
      class CellValue < Lutaml::Model::Serializable
          attribute :text, String

          xml do
            root 'v'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_element '', to: :text, render_nil: false
          end
      end
    end
  end
end
