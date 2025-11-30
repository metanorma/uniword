# frozen_string_literal: true

require 'lutaml/model'

module Uniword
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
            element 'blipFill'
            namespace Uniword::Ooxml::Namespaces::Picture
            mixed_content

            map_element 'blip', to: :blip
            map_element 'srcRect', to: :src_rect, render_nil: false
            map_element 'stretch', to: :stretch, render_nil: false
            map_element 'tile', to: :tile, render_nil: false
          end
      end
    end
end
