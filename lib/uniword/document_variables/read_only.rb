# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentVariables
    # Read-only flag for variables
    #
    # Generated from OOXML schema: document_variables.yml
    # Element: <dv:read_only>
    class ReadOnly < Lutaml::Model::Serializable
      include Uniword::Properties::BooleanElement
      attribute :val, :string, default: nil
      include Uniword::Properties::BooleanValSetter

      xml do
        element 'read_only'
        namespace Uniword::Ooxml::Namespaces::DocumentVariables
        map_attribute 'val', to: :val, render_nil: false, render_default: false
      end
    end
  end
end
