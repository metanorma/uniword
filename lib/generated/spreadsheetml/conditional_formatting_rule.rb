# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'cfRule'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :type
            map_attribute 'true', to: :priority
            map_element 'formula', to: :formula, render_nil: false
          end
      end
    end
  end
end
