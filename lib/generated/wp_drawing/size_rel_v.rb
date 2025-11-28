# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module WpDrawing
      # Relative vertical size
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:sizeRelV>
      class SizeRelV < Lutaml::Model::Serializable
          attribute :relative_from, String
          attribute :pct_height, Integer

          xml do
            root 'sizeRelV'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'
            mixed_content

            map_attribute 'true', to: :relative_from
            map_element 'pctHeight', to: :pct_height, render_nil: false
          end
      end
    end
  end
end
