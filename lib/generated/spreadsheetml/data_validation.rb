# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Data validation rule
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:dataValidation>
      class DataValidation < Lutaml::Model::Serializable
          attribute :type, String
          attribute :operator, String
          attribute :sqref, String
          attribute :formula1, String
          attribute :formula2, String
          attribute :show_input_message, String
          attribute :show_error_message, String
          attribute :prompt_title, String
          attribute :prompt, String
          attribute :error_title, String
          attribute :error, String

          xml do
            root 'dataValidation'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :type
            map_attribute 'true', to: :operator
            map_attribute 'true', to: :sqref
            map_element 'formula1', to: :formula1, render_nil: false
            map_element 'formula2', to: :formula2, render_nil: false
            map_attribute 'true', to: :show_input_message
            map_attribute 'true', to: :show_error_message
            map_attribute 'true', to: :prompt_title
            map_attribute 'true', to: :prompt
            map_attribute 'true', to: :error_title
            map_attribute 'true', to: :error
          end
      end
    end
  end
end
