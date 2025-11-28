# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Data validation collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:dataValidations>
      class DataValidations < Lutaml::Model::Serializable
          attribute :count, Integer
          attribute :validations, DataValidation, collection: true, default: -> { [] }

          xml do
            root 'dataValidations'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :count
            map_element 'dataValidation', to: :validations, render_nil: false
          end
      end
    end
  end
end
