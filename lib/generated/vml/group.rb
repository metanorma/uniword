# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML shape group container
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:group>
      class Group < Lutaml::Model::Serializable
          attribute :id, String
          attribute :style, String
          attribute :coordsize, String
          attribute :coordorigin, String
          attribute :shapes, String, collection: true, default: -> { [] }

          xml do
            root 'group'
            namespace 'urn:schemas-microsoft-com:vml', 'v'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :style
            map_attribute 'true', to: :coordsize
            map_attribute 'true', to: :coordorigin
            map_element '', to: :shapes, render_nil: false
          end
      end
    end
  end
end
