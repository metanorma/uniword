# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Individual cell
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:c>
      class Cell < Lutaml::Model::Serializable
          attribute :r, String
          attribute :s, Integer
          attribute :t, String
          attribute :v, CellValue
          attribute :f, CellFormula

          xml do
            root 'c'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :r
            map_attribute 'true', to: :s
            map_attribute 'true', to: :t
            map_element 'v', to: :v, render_nil: false
            map_element 'f', to: :f, render_nil: false
          end
      end
    end
  end
end
