# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Cell formats collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:cellXfs>
      class CellFormats < Lutaml::Model::Serializable
          attribute :count, Integer
          attribute :formats, CellFormat, collection: true, default: -> { [] }

          xml do
            root 'cellXfs'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :count
            map_element 'xf', to: :formats, render_nil: false
          end
      end
    end
  end
end
