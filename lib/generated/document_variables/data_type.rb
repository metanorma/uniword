# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentVariables
      # Data type specification for variables
      #
      # Generated from OOXML schema: document_variables.yml
      # Element: <dv:data_type>
      class DataType < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'data_type'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/docVars', 'dv'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
