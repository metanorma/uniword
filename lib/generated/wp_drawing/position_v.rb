# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module WpDrawing
      # Vertical positioning
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:positionV>
      class PositionV < Lutaml::Model::Serializable
          attribute :relative_from, String
          attribute :align, String
          attribute :pos_offset, Integer

          xml do
            root 'positionV'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'
            mixed_content

            map_attribute 'true', to: :relative_from
            map_element '', to: :align, render_nil: false
            map_element 'posOffset', to: :pos_offset, render_nil: false
          end
      end
    end
  end
end
