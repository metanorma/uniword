# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Spreadsheetml
    # Data validation rule
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:dataValidation>
    class DataValidation < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :operator, :string
      attribute :sqref, :string
      attribute :formula1, :string
      attribute :formula2, :string
      attribute :show_input_message, :string
      attribute :show_error_message, :string
      attribute :prompt_title, :string
      attribute :prompt, :string
      attribute :error_title, :string
      attribute :error, :string

      xml do
        element "dataValidation"
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute "type", to: :type
        map_attribute "operator", to: :operator
        map_attribute "sqref", to: :sqref
        map_element "formula1", to: :formula1, render_nil: false
        map_element "formula2", to: :formula2, render_nil: false
        map_attribute "show-input-message", to: :show_input_message
        map_attribute "show-error-message", to: :show_error_message
        map_attribute "prompt-title", to: :prompt_title
        map_attribute "prompt", to: :prompt
        map_attribute "error-title", to: :error_title
        map_attribute "error", to: :error
      end
    end
  end
end
