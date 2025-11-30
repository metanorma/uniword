# frozen_string_literal: true

require 'lutaml/model'

module Uniword
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
            element 'workbookView'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML

            map_attribute 'active-tab', to: :active_tab
            map_attribute 'window-width', to: :window_width
            map_attribute 'window-height', to: :window_height
          end
      end
    end
end
