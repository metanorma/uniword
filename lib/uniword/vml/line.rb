# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Vml
      # VML line shape
      #
      # Generated from OOXML schema: vml.yml
      # Element: <v:line>
      class Line < Lutaml::Model::Serializable
          attribute :id, String
          attribute :style, String
          attribute :from, String
          attribute :to, String
          attribute :strokecolor, String
          attribute :strokeweight, String
          attribute :stroke, String

          xml do
            element 'line'
            namespace Uniword::Ooxml::Namespaces::Vml

            map_attribute 'id', to: :id
            map_attribute 'style', to: :style
            map_attribute 'from', to: :from
            map_attribute 'to', to: :to
            map_attribute 'strokecolor', to: :strokecolor
            map_attribute 'strokeweight', to: :strokeweight
            map_element '', to: :stroke, render_nil: false
          end
      end
    end
  end
end
