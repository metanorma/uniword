# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentVariables
      # Default value setting for variables
      #
      # Generated from OOXML schema: document_variables.yml
      # Element: <dv:default_value>
      class DefaultValue < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'default_value'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/docVars', 'dv'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
