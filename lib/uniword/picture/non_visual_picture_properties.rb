# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Picture
    # Non-visual picture properties
    #
    # Generated from OOXML schema: picture.yml
    # Element: <pic:nvPicPr>
    class NonVisualPictureProperties < Lutaml::Model::Serializable
      attribute :c_nv_pr, String
      attribute :c_nv_pic_pr, NonVisualPictureDrawingProperties

      xml do
        element 'nvPicPr'
        namespace Uniword::Ooxml::Namespaces::Picture
        mixed_content

        map_element 'cNvPr', to: :c_nv_pr
        map_element 'cNvPicPr', to: :c_nv_pic_pr
      end
    end
  end
end
