# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Picture
      # Source rectangle for picture cropping
      #
      # Generated from OOXML schema: picture.yml
      # Element: <pic:srcRect>
      class PictureSourceRect < Lutaml::Model::Serializable
          attribute :l, Integer
          attribute :t, Integer
          attribute :r, Integer
          attribute :b, Integer

          xml do
            root 'srcRect'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/picture', 'pic'

            map_attribute 'true', to: :l
            map_attribute 'true', to: :t
            map_attribute 'true', to: :r
            map_attribute 'true', to: :b
          end
      end
    end
  end
end
