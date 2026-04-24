# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module WpDrawing
    # Non-Visual Drawing Properties
    # Contains locking and other non-visual settings
    class NonVisualDrawingProps < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :graphic_frame_locks, Drawingml::GraphicFrameLocks

      xml do
        element "cNvGraphicFramePr"
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

        map_element "graphicFrameLocks", to: :graphic_frame_locks,
                                         render_nil: false
      end
    end
  end
end
