# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Picture
    # Source rectangle for picture cropping
    #
    # Generated from OOXML schema: picture.yml
    # Element: <pic:srcRect>
    class PictureSourceRect < Lutaml::Model::Serializable
      attribute :l, :integer
      attribute :t, :integer
      attribute :r, :integer
      attribute :b, :integer

      xml do
        element 'srcRect'
        namespace Uniword::Ooxml::Namespaces::Picture

        map_attribute 'l', to: :l
        map_attribute 't', to: :t
        map_attribute 'r', to: :r
        map_attribute 'b', to: :b
      end
    end
  end
end
