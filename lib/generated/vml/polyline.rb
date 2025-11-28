# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML polyline shape
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:polyline>
      class Polyline < Lutaml::Model::Serializable
          attribute :id, String
          attribute :style, String
          attribute :points, String
          attribute :strokecolor, String
          attribute :strokeweight, String
          attribute :stroke, String

          xml do
            root 'polyline'
            namespace 'urn:schemas-microsoft-com:vml', 'v'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :style
            map_attribute 'true', to: :points
            map_attribute 'true', to: :strokecolor
            map_attribute 'true', to: :strokeweight
            map_element '', to: :stroke, render_nil: false
          end
      end
    end
  end
end
