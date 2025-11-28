# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentVariables
      # Read-only flag for variables
      #
      # Generated from OOXML schema: document_variables.yml
      # Element: <dv:read_only>
      class ReadOnly < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            root 'read_only'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/docVars', 'dv'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
