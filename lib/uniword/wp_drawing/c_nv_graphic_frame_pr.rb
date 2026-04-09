# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Non-visual graphic frame properties
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:cNvGraphicFramePr>
    class CNvGraphicFramePr < Lutaml::Model::Serializable
      attribute :graphic_frame_locks, :string

      xml do
        element 'cNvGraphicFramePr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        map_element 'graphicFrameLocks', to: :graphic_frame_locks, render_nil: false
      end
    end
  end
end
