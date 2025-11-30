# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Row page breaks
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:rowBreaks>
      class RowBreaks < Lutaml::Model::Serializable
          attribute :count, Integer
          attribute :breaks, String, collection: true, default: -> { [] }

          xml do
            element 'rowBreaks'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML
            mixed_content

            map_attribute 'count', to: :count
            map_element 'brk', to: :breaks, render_nil: false
          end
      end
    end
end
