# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # SpreadsheetML workbook root element
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:workbook>
      class Workbook < Lutaml::Model::Serializable
          attribute :sheets, Sheets
          attribute :defined_names, DefinedNames
          attribute :calc_pr, CalcProperties
          attribute :workbook_pr, WorkbookProperties
          attribute :book_views, BookViews

          xml do
            root 'workbook'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'sheets', to: :sheets
            map_element 'definedNames', to: :defined_names, render_nil: false
            map_element 'calcPr', to: :calc_pr, render_nil: false
            map_element 'workbookPr', to: :workbook_pr, render_nil: false
            map_element 'bookViews', to: :book_views, render_nil: false
          end
      end
    end
  end
end
