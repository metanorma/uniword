# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module WpDrawing
      # Wrapping polygon point
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:lineTo>
      class LineTo < Lutaml::Model::Serializable
          attribute :x, Integer
          attribute :y, Integer

          xml do
            element 'lineTo'
            namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

            map_attribute 'x', to: :x
            map_attribute 'y', to: :y
          end
      end
    end
end
