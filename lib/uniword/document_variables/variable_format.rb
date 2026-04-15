# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module DocumentVariables
    # Format specification for variable display
    #
    # Generated from OOXML schema: document_variables.yml
    # Element: <dv:variable_format>
    class VariableFormat < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "variable_format"
        namespace Uniword::Ooxml::Namespaces::DocumentVariables

        map_attribute "val", to: :val
      end
    end
  end
end
