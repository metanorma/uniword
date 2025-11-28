# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Picture
      # Picture fill using blip reference
      #
      # Generated from OOXML schema: picture.yml
      # Element: <pic:blipFill>
      class PictureBlipFill < Lutaml::Model::Serializable
          attribute :blip, String
          attribute :src_rect, PictureSourceRect
          attribute :stretch, PictureStretch
          attribute :tile, Tile

          xml do
            root 'blipFill'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/picture', 'pic'
            mixed_content

            map_element 'blip', to: :blip
            map_element 'srcRect', to: :src_rect, render_nil: false
            map_element 'stretch', to: :stretch, render_nil: false
            map_element 'tile', to: :tile, render_nil: false
          end
      end
    end
  end
end
