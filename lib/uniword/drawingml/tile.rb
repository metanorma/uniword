# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Tile fill mode
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:tile>
    class Tile < Lutaml::Model::Serializable
      attribute :tx, :integer
      attribute :ty, :integer
      attribute :sx, :integer
      attribute :sy, :integer
      attribute :flip, :string
      attribute :algn, :string

      xml do
        element "tile"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "tx", to: :tx, render_nil: false
        map_attribute "ty", to: :ty, render_nil: false
        map_attribute "sx", to: :sx, render_nil: false
        map_attribute "sy", to: :sy, render_nil: false
        map_attribute "flip", to: :flip, render_nil: false
        map_attribute "algn", to: :algn, render_nil: false
      end
    end
  end
end
