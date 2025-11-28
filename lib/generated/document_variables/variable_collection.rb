# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentVariables
      # Collection of related variables
      #
      # Generated from OOXML schema: document_variables.yml
      # Element: <dv:variable_collection>
      class VariableCollection < Lutaml::Model::Serializable
          attribute :variables, DocVar, collection: true, default: -> { [] }
          attribute :name, :string

          xml do
            root 'variable_collection'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/docVars', 'dv'
            mixed_content

            map_element 'variable', to: :variables, render_nil: false
            map_attribute 'name', to: :name
          end
      end
    end
  end
end
