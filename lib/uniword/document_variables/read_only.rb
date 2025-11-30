# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentVariables
    # Read-only flag for variables
    #
    # Generated from OOXML schema: document_variables.yml
    # Element: <dv:read_only>
    class ReadOnly < Lutaml::Model::Serializable
      attribute :val, :boolean

      xml do
        element 'read_only'
        namespace Uniword::Ooxml::Namespaces::DocumentVariables

        map_attribute 'val', to: :val
      end
    end
  end
end
