# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module DocumentVariables
      # Collection of related variables
      #
      # Generated from OOXML schema: document_variables.yml
      # Element: <dv:variable_collection>
      class VariableCollection < Lutaml::Model::Serializable
          attribute :variables, DocVar, collection: true, default: -> { [] }
          attribute :name, :string

          xml do
            element 'variable_collection'
            namespace Uniword::Ooxml::Namespaces::DocumentVariables
            mixed_content

            map_element 'variable', to: :variables, render_nil: false
            map_attribute 'name', to: :name
          end
      end
    end
end
