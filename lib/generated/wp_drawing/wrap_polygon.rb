# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module WpDrawing
      # Text wrapping polygon
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:wrapPolygon>
      class WrapPolygon < Lutaml::Model::Serializable
          attribute :edited, String
          attribute :start, String
          attribute :line_to, String, collection: true, default: -> { [] }

          xml do
            root 'wrapPolygon'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'
            mixed_content

            map_attribute 'true', to: :edited
            map_element '', to: :start, render_nil: false
            map_element 'lineTo', to: :line_to, render_nil: false
          end
      end
    end
  end
end
