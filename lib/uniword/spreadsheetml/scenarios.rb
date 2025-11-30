# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Scenario definitions
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:scenarios>
      class Scenarios < Lutaml::Model::Serializable
          attribute :current, Integer
          attribute :show, Integer
          attribute :entries, String, collection: true, default: -> { [] }

          xml do
            element 'scenarios'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML
            mixed_content

            map_attribute 'current', to: :current
            map_attribute 'show', to: :show
            map_element 'scenario', to: :entries, render_nil: false
          end
      end
    end
end
