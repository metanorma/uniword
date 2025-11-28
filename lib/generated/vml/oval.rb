# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML oval/ellipse shape
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:oval>
      class Oval < Lutaml::Model::Serializable
          attribute :id, String
          attribute :style, String
          attribute :fillcolor, String
          attribute :strokecolor, String
          attribute :strokeweight, String
          attribute :fill, String
          attribute :stroke, String

          xml do
            root 'oval'
            namespace 'urn:schemas-microsoft-com:vml', 'v'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :style
            map_attribute 'true', to: :fillcolor
            map_attribute 'true', to: :strokecolor
            map_attribute 'true', to: :strokeweight
            map_element '', to: :fill, render_nil: false
            map_element '', to: :stroke, render_nil: false
          end
      end
    end
  end
end
