# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module WpDrawing
      # Square text wrapping
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:wrapSquare>
      class WrapSquare < Lutaml::Model::Serializable
          attribute :wrap_text, String
          attribute :dist_t, Integer
          attribute :dist_b, Integer
          attribute :dist_l, Integer
          attribute :dist_r, Integer
          attribute :effect_extent, String

          xml do
            root 'wrapSquare'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'
            mixed_content

            map_attribute 'true', to: :wrap_text
            map_attribute 'true', to: :dist_t
            map_attribute 'true', to: :dist_b
            map_attribute 'true', to: :dist_l
            map_attribute 'true', to: :dist_r
            map_element 'effectExtent', to: :effect_extent, render_nil: false
          end
      end
    end
  end
end
