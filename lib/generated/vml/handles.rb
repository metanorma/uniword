# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML adjustment handles for shape manipulation
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:handles>
      class Handles < Lutaml::Model::Serializable
          attribute :handles, String, collection: true, default: -> { [] }

          xml do
            root 'handles'
            namespace 'urn:schemas-microsoft-com:vml', 'v'
            mixed_content

            map_element 'h', to: :handles, render_nil: false
          end
      end
    end
  end
end
