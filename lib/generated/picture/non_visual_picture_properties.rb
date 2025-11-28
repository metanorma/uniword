# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Picture
      # Non-visual picture properties
      #
      # Generated from OOXML schema: picture.yml
      # Element: <pic:nvPicPr>
      class NonVisualPictureProperties < Lutaml::Model::Serializable
          attribute :c_nv_pr, String
          attribute :c_nv_pic_pr, NonVisualPictureDrawingProperties

          xml do
            root 'nvPicPr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/picture', 'pic'
            mixed_content

            map_element 'cNvPr', to: :c_nv_pr
            map_element 'cNvPicPr', to: :c_nv_pic_pr
          end
      end
    end
  end
end
