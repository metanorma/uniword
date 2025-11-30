# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Workbook properties
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:workbookPr>
    class WorkbookProperties < Lutaml::Model::Serializable
      attribute :date1904, :string
      attribute :show_ink_annotation, :string
      attribute :default_theme_version, :integer

      xml do
        element 'workbookPr'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'date1904', to: :date1904
        map_attribute 'show-ink-annotation', to: :show_ink_annotation
        map_attribute 'default-theme-version', to: :default_theme_version
      end
    end
  end
end
