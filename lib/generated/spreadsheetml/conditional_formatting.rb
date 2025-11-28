# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Conditional formatting
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:conditionalFormatting>
      class ConditionalFormatting < Lutaml::Model::Serializable
          attribute :sqref, String
          attribute :rules, ConditionalFormattingRule, collection: true, default: -> { [] }

          xml do
            root 'conditionalFormatting'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :sqref
            map_element 'cfRule', to: :rules, render_nil: false
          end
      end
    end
  end
end
