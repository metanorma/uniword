# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Tile rectangle
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:tileRect>
    class TileRect < Lutaml::Model::Serializable
      attribute :l, :integer
      attribute :t, :integer
      attribute :r, :integer
      attribute :b, :integer

      xml do
        element "tileRect"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "l", to: :l
        map_attribute "t", to: :t
        map_attribute "r", to: :r
        map_attribute "b", to: :b
      end
    end
  end
end
