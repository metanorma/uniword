# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Conditional formatting
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:conditionalFormatting>
    class ConditionalFormatting < Lutaml::Model::Serializable
      attribute :sqref, :string
      attribute :rules, ConditionalFormattingRule, collection: true, initialize_empty: true

      xml do
        element 'conditionalFormatting'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute 'sqref', to: :sqref
        map_element 'cfRule', to: :rules, render_nil: false
      end
    end
  end
end
