# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module DocumentVariables
    # Scope specification for variables
    #
    # Generated from OOXML schema: document_variables.yml
    # Element: <dv:variable_scope>
    class VariableScope < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "variable_scope"
        namespace Uniword::Ooxml::Namespaces::DocumentVariables

        map_attribute "val", to: :val
      end
    end
  end
end
