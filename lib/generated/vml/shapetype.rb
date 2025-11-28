# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML shape type definition (template)
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:shapetype>
      class Shapetype < Lutaml::Model::Serializable
          attribute :id, String
          attribute :coordsize, String
          attribute :coordorigin, String
          attribute :path, String
          attribute :stroke, String
          attribute :fill, String

          xml do
            root 'shapetype'
            namespace 'urn:schemas-microsoft-com:vml', 'v'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :coordsize
            map_attribute 'true', to: :coordorigin
            map_attribute 'true', to: :path
            map_element '', to: :stroke, render_nil: false
            map_element '', to: :fill, render_nil: false
          end
      end
    end
  end
end
