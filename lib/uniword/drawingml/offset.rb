# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Position offset
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:false>
      class Offset < Lutaml::Model::Serializable
          attribute :x, Integer
          attribute :y, Integer

          xml do
            element 'false'
            namespace Uniword::Ooxml::Namespaces::DrawingML

            map_attribute 'x', to: :x
            map_attribute 'y', to: :y
          end
      end
    end
end
