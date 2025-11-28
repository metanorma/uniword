# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'scenarios'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :current
            map_attribute 'true', to: :show
            map_element 'scenario', to: :entries, render_nil: false
          end
      end
    end
  end
end
