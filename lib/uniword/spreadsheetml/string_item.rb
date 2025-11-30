# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Shared string item
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:si>
    class StringItem < Lutaml::Model::Serializable
      attribute :t, Text
      attribute :r, RichTextRun, collection: true, default: -> { [] }
      attribute :phonetic_pr, PhoneticProperties

      xml do
        element 'si'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element 't', to: :t, render_nil: false
        map_element 'r', to: :r, render_nil: false
        map_element 'phoneticPr', to: :phonetic_pr, render_nil: false
      end
    end
  end
end
