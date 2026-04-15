# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Rich text run
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:r>
    class RichTextRun < Lutaml::Model::Serializable
      attribute :r_pr, RunProperties
      attribute :t, Text

      xml do
        element "r"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element "rPr", to: :r_pr, render_nil: false
        map_element "t", to: :t
      end
    end
  end
end
