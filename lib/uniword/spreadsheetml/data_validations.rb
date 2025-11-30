# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Data validation collection
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:dataValidations>
    class DataValidations < Lutaml::Model::Serializable
      attribute :count, Integer
      attribute :validations, DataValidation, collection: true, default: -> { [] }

      xml do
        element 'dataValidations'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute 'count', to: :count
        map_element 'dataValidation', to: :validations, render_nil: false
      end
    end
  end
end
