# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Workbook properties
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:workbookPr>
      class WorkbookProperties < Lutaml::Model::Serializable
          attribute :date1904, String
          attribute :show_ink_annotation, String
          attribute :default_theme_version, Integer

          xml do
            root 'workbookPr'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :date1904
            map_attribute 'true', to: :show_ink_annotation
            map_attribute 'true', to: :default_theme_version
          end
      end
    end
  end
end
