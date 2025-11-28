# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module WpDrawing
      # Position offset in EMUs
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:posOffset>
      class PosOffset < Lutaml::Model::Serializable
          attribute :value, Integer

          xml do
            root 'posOffset'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'

            map_element '', to: :value, render_nil: false
          end
      end
    end
  end
end
