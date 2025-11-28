# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Picture
      # Stretch fill properties
      #
      # Generated from OOXML schema: picture.yml
      # Element: <pic:stretch>
      class PictureStretch < Lutaml::Model::Serializable
          attribute :fill_rect, FillRect

          xml do
            root 'stretch'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/picture', 'pic'
            mixed_content

            map_element 'fillRect', to: :fill_rect, render_nil: false
          end
      end
    end
  end
end
