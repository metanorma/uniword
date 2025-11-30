# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Picture
      # Non-visual picture drawing properties
      #
      # Generated from OOXML schema: picture.yml
      # Element: <pic:cNvPicPr>
      class NonVisualPictureDrawingProperties < Lutaml::Model::Serializable
          attribute :prefer_relative_resize, String
          attribute :pic_locks, PictureLocks

          xml do
            element 'cNvPicPr'
            namespace Uniword::Ooxml::Namespaces::Picture
            mixed_content

            map_attribute 'prefer-relative-resize', to: :prefer_relative_resize
            map_element 'picLocks', to: :pic_locks, render_nil: false
          end
      end
    end
end
