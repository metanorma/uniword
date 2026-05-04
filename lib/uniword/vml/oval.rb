# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Vml
    # VML oval/ellipse shape
    #
    # Generated from OOXML schema: vml.yml
    # Element: <v:oval>
    class Oval < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :style, :string
      attribute :fillcolor, :string
      attribute :strokecolor, :string
      attribute :strokeweight, :string
      attribute :fill, Fill
      attribute :stroke, Stroke

      xml do
        element "oval"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "id", to: :id
        map_attribute "style", to: :style
        map_attribute "fillcolor", to: :fillcolor
        map_attribute "strokecolor", to: :strokecolor
        map_attribute "strokeweight", to: :strokeweight
        map_element "fill", to: :fill, render_nil: false
        map_element "stroke", to: :stroke, render_nil: false
      end
    end
  end
end
