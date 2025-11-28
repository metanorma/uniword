# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Spreadsheet row
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:row>
      class Row < Lutaml::Model::Serializable
          attribute :r, Integer
          attribute :spans, String
          attribute :ht, String
          attribute :custom_height, String
          attribute :hidden, String
          attribute :cells, Cell, collection: true, default: -> { [] }

          xml do
            root 'row'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :r
            map_attribute 'true', to: :spans
            map_attribute 'true', to: :ht
            map_attribute 'true', to: :custom_height
            map_attribute 'true', to: :hidden
            map_element 'c', to: :cells, render_nil: false
          end
      end
    end
  end
end
