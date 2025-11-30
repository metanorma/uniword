# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module WpDrawing
      # Simple positioning coordinates
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:simplePos>
      class SimplePos < Lutaml::Model::Serializable
          attribute :x, Integer
          attribute :y, Integer

          xml do
            element 'simplePos'
            namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

            map_attribute 'x', to: :x
            map_attribute 'y', to: :y
          end
      end
    end
end
