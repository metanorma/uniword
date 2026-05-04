# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Vml
    # VML polyline shape
    #
    # Generated from OOXML schema: vml.yml
    # Element: <v:polyline>
    class Polyline < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :style, :string
      attribute :points, :string
      attribute :strokecolor, :string
      attribute :strokeweight, :string
      attribute :stroke, Stroke

      xml do
        element "polyline"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "id", to: :id
        map_attribute "style", to: :style
        map_attribute "points", to: :points
        map_attribute "strokecolor", to: :strokecolor
        map_attribute "strokeweight", to: :strokeweight
        map_element "stroke", to: :stroke, render_nil: false
      end
    end
  end
end
