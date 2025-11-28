# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentVariables
      # Scope specification for variables
      #
      # Generated from OOXML schema: document_variables.yml
      # Element: <dv:variable_scope>
      class VariableScope < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'variable_scope'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/docVars', 'dv'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
