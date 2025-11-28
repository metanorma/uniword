# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module WpDrawing
      # Non-visual graphic frame properties
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:cNvGraphicFramePr>
      class CNvGraphicFramePr < Lutaml::Model::Serializable
          attribute :graphic_frame_locks, String

          xml do
            root 'cNvGraphicFramePr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'
            mixed_content

            map_element 'graphicFrameLocks', to: :graphic_frame_locks, render_nil: false
          end
      end
    end
  end
end
