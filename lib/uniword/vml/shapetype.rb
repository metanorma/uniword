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
            element 'shapetype'
            namespace Uniword::Ooxml::Namespaces::Vml

            map_attribute 'id', to: :id
            map_attribute 'coordsize', to: :coordsize
            map_attribute 'coordorigin', to: :coordorigin
            map_attribute 'path', to: :path
            map_element '', to: :stroke, render_nil: false
            map_element '', to: :fill, render_nil: false
          end
      end
    end
  end
end
