# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Line properties
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:ln>
      class LineProperties < Lutaml::Model::Serializable
          attribute :w, Integer

          xml do
            element 'ln'
            namespace Uniword::Ooxml::Namespaces::DrawingML

            map_attribute 'w', to: :w
          end
      end
    end
end
