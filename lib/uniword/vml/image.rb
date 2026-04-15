# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Vml
    # VML image element (external image reference)
    #
    # Element: <v:image>
    class Image < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :style, :string
      attribute :src, :string
      attribute :crop_left, :string
      attribute :crop_top, :string
      attribute :crop_right, :string
      attribute :crop_bottom, :string
      attribute :fillcolor, :string
      attribute :strokecolor, :string
      attribute :strokeweight, :string
      attribute :coordsize, :string
      attribute :coordorigin, :string
      attribute :filled, :string
      attribute :stroked, :string

      xml do
        element "image"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "id", to: :id
        map_attribute "style", to: :style
        map_attribute "src", to: :src
        map_attribute "cropLeft", to: :crop_left
        map_attribute "cropTop", to: :crop_top
        map_attribute "cropRight", to: :crop_right
        map_attribute "cropBottom", to: :crop_bottom
        map_attribute "fillcolor", to: :fillcolor
        map_attribute "strokecolor", to: :strokecolor
        map_attribute "strokeweight", to: :strokeweight
        map_attribute "coordsize", to: :coordsize
        map_attribute "coordorigin", to: :coordorigin
        map_attribute "filled", to: :filled
        map_attribute "stroked", to: :stroked
      end
    end
  end
end
