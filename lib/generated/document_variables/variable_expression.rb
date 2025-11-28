# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentVariables
      # Expression for computed variables
      #
      # Generated from OOXML schema: document_variables.yml
      # Element: <dv:variable_expression>
      class VariableExpression < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'variable_expression'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/docVars', 'dv'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
