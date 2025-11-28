# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module WpDrawing
      # Object effect extent (shadow/glow space)
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:effectExtent>
      class EffectExtent < Lutaml::Model::Serializable
          attribute :l, Integer
          attribute :t, Integer
          attribute :r, Integer
          attribute :b, Integer

          xml do
            root 'effectExtent'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'

            map_attribute 'true', to: :l
            map_attribute 'true', to: :t
            map_attribute 'true', to: :r
            map_attribute 'true', to: :b
          end
      end
    end
  end
end
