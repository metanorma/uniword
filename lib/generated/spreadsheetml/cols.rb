# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Column definitions collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:cols>
      class Cols < Lutaml::Model::Serializable
          attribute :col_entries, Col, collection: true, default: -> { [] }

          xml do
            root 'cols'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'col', to: :col_entries, render_nil: false
          end
      end
    end
  end
end
