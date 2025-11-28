# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module WpDrawing
      # Drawing object size extent
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:extent>
      class Extent < Lutaml::Model::Serializable
          attribute :cx, Integer
          attribute :cy, Integer

          xml do
            root 'extent'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'

            map_attribute 'true', to: :cx
            map_attribute 'true', to: :cy
          end
      end
    end
  end
end
