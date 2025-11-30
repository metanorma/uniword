# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Conditional formatting rule
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:cfRule>
      class ConditionalFormattingRule < Lutaml::Model::Serializable
          attribute :type, String
          attribute :priority, Integer
          attribute :formula, String, collection: true, default: -> { [] }

          xml do
            element 'cfRule'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML
            mixed_content

            map_attribute 'type', to: :type
            map_attribute 'priority', to: :priority
            map_element 'formula', to: :formula, render_nil: false
          end
      end
    end
end
