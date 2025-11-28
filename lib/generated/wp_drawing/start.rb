# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module WpDrawing
      # Wrapping polygon start point
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:start>
      class Start < Lutaml::Model::Serializable
          attribute :x, Integer
          attribute :y, Integer

          xml do
            root 'start'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'

            map_attribute 'true', to: :x
            map_attribute 'true', to: :y
          end
      end
    end
  end
end
