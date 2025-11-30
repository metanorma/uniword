# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML rectangle shape
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:rect>
      class Rect < Lutaml::Model::Serializable
          attribute :id, String
          attribute :style, String
          attribute :fillcolor, String
          attribute :strokecolor, String
          attribute :strokeweight, String
          attribute :fill, String
          attribute :stroke, String

          xml do
            element 'rect'
            namespace Uniword::Ooxml::Namespaces::Vml

            map_attribute 'id', to: :id
            map_attribute 'style', to: :style
            map_attribute 'fillcolor', to: :fillcolor
            map_attribute 'strokecolor', to: :strokecolor
            map_attribute 'strokeweight', to: :strokeweight
            map_element '', to: :fill, render_nil: false
            map_element '', to: :stroke, render_nil: false
          end
      end
    end
  end
end
