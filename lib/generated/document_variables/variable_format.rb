# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentVariables
      # Format specification for variable display
      #
      # Generated from OOXML schema: document_variables.yml
      # Element: <dv:variable_format>
      class VariableFormat < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'variable_format'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/docVars', 'dv'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
