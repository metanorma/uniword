# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentVariables
    # Expression for computed variables
    #
    # Generated from OOXML schema: document_variables.yml
    # Element: <dv:variable_expression>
    class VariableExpression < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'variable_expression'
        namespace Uniword::Ooxml::Namespaces::DocumentVariables

        map_attribute 'val', to: :val
      end
    end
  end
end
