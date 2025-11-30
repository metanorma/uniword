# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Hue offset
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:hueOff>
      class HueOffset < Lutaml::Model::Serializable
          attribute :val, Integer

          xml do
            element 'hueOff'
            namespace Uniword::Ooxml::Namespaces::DrawingML

            map_attribute 'val', to: :val
          end
      end
    end
end
