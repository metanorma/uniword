# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Workbook view settings
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:workbookView>
      class WorkbookView < Lutaml::Model::Serializable
          attribute :active_tab, Integer
          attribute :window_width, Integer
          attribute :window_height, Integer

          xml do
            root 'workbookView'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :active_tab
            map_attribute 'true', to: :window_width
            map_attribute 'true', to: :window_height
          end
      end
    end
  end
end
