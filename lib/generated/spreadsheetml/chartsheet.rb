# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Chart sheet definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:chartsheet>
      class Chartsheet < Lutaml::Model::Serializable
          attribute :sheet_views, String
          attribute :drawing, Drawing

          xml do
            root 'chartsheet'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'sheetViews', to: :sheet_views, render_nil: false
            map_element 'drawing', to: :drawing, render_nil: false
          end
      end
    end
  end
end
