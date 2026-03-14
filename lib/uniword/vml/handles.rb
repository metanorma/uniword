# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Vml
    # VML adjustment handles for shape manipulation
    #
    # Generated from OOXML schema: vml.yml
    # Element: <v:handles>
    class Handles < Lutaml::Model::Serializable
      # Pattern 0: Attributes BEFORE xml mappings
      attribute :handles, Handle, collection: true, default: -> { [] }

      xml do
        element 'handles'
        namespace Uniword::Ooxml::Namespaces::Vml
        mixed_content

        map_element 'h', to: :handles, render_nil: false
      end
    end
  end
end
