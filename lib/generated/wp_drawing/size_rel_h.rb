# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module WpDrawing
      # Relative horizontal size
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:sizeRelH>
      class SizeRelH < Lutaml::Model::Serializable
          attribute :relative_from, String
          attribute :pct_width, Integer

          xml do
            root 'sizeRelH'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'
            mixed_content

            map_attribute 'true', to: :relative_from
            map_element 'pctWidth', to: :pct_width, render_nil: false
          end
      end
    end
  end
end
