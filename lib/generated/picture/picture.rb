# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Picture
      # Picture element
      #
      # Generated from OOXML schema: picture.yml
      # Element: <pic:pic>
      class Picture < Lutaml::Model::Serializable
          attribute :nv_pic_pr, NonVisualPictureProperties
          attribute :blip_fill, PictureBlipFill
          attribute :sp_pr, String

          xml do
            root 'pic'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/picture', 'pic'
            mixed_content

            map_element 'nvPicPr', to: :nv_pic_pr
            map_element 'blipFill', to: :blip_fill
            map_element 'spPr', to: :sp_pr
          end
      end
    end
  end
end
