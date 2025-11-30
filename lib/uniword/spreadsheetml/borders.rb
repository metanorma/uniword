# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Border collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:borders>
      class Borders < Lutaml::Model::Serializable
          attribute :count, Integer
          attribute :border_entries, Border, collection: true, default: -> { [] }

          xml do
            element 'borders'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML
            mixed_content

            map_attribute 'count', to: :count
            map_element 'border', to: :border_entries, render_nil: false
          end
      end
    end
end
