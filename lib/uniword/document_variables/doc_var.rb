# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentVariables
    # Individual document variable with name and value
    #
    # Generated from OOXML schema: document_variables.yml
    # Element: <dv:doc_var>
    class DocVar < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :val, :string

      xml do
        element 'doc_var'
        namespace Uniword::Ooxml::Namespaces::DocumentVariables

        map_attribute 'name', to: :name
        map_attribute 'val', to: :val
      end
    end
  end
end
