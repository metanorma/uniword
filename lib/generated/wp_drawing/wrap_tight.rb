# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module WpDrawing
      # Tight text wrapping along object edges
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:wrapTight>
      class WrapTight < Lutaml::Model::Serializable
          attribute :wrap_text, String
          attribute :dist_l, Integer
          attribute :dist_r, Integer
          attribute :wrap_polygon, String

          xml do
            root 'wrapTight'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'
            mixed_content

            map_attribute 'true', to: :wrap_text
            map_attribute 'true', to: :dist_l
            map_attribute 'true', to: :dist_r
            map_element 'wrapPolygon', to: :wrap_polygon, render_nil: false
          end
      end
    end
  end
end
