# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Tint
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:tint>
      class Tint < Lutaml::Model::Serializable
          attribute :val, Integer

          xml do
            element 'tint'
            namespace Uniword::Ooxml::Namespaces::DrawingML

            map_attribute 'val', to: :val
          end
      end
    end
end
