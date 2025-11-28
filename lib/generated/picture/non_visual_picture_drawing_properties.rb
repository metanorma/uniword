# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Picture
      # Non-visual picture drawing properties
      #
      # Generated from OOXML schema: picture.yml
      # Element: <pic:cNvPicPr>
      class NonVisualPictureDrawingProperties < Lutaml::Model::Serializable
          attribute :prefer_relative_resize, String
          attribute :pic_locks, PictureLocks

          xml do
            root 'cNvPicPr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/picture', 'pic'
            mixed_content

            map_attribute 'true', to: :prefer_relative_resize
            map_element 'picLocks', to: :pic_locks, render_nil: false
          end
      end
    end
  end
end
