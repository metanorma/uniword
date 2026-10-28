# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Picture
    # Fill rectangle insets
    #
    # Generated from OOXML schema: picture.yml
    # Element: <a:fillRect> (child of a:stretch in CT_BlipFillProperties)
    class FillRect < Lutaml::Model::Serializable
      attribute :l, :integer
      attribute :t, :integer
      attribute :r, :integer
      attribute :b, :integer

      xml do
        element "fillRect"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "l", to: :l
        map_attribute "t", to: :t
        map_attribute "r", to: :r
        map_attribute "b", to: :b
      end
    end
  end
end
