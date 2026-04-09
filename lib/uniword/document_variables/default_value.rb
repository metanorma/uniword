# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentVariables
    # Default value setting for variables
    #
    # Generated from OOXML schema: document_variables.yml
    # Element: <dv:default_value>
    class DefaultValue < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element 'default_value'
        namespace Uniword::Ooxml::Namespaces::DocumentVariables

        map_attribute 'val', to: :val
      end
    end
  end
end
