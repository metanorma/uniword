# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Non-Visual Drawing Properties
    # Contains locking and other non-visual settings
    class NonVisualDrawingProps < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      # Currently minimal - locks will be added when needed

      xml do
        element 'cNvGraphicFramePr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content
      end
    end
  end
end
