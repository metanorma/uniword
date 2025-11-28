# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module WpDrawing
      # No text wrapping
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:wrapNone>
      class WrapNone < Lutaml::Model::Serializable


          xml do
            root 'wrapNone'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'

          end
      end
    end
  end
end
