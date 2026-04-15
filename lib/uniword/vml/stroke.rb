# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Vml
    # VML stroke properties
    #
    # Generated from OOXML schema: vml.yml
    # Element: <v:stroke>
    class Stroke < Lutaml::Model::Serializable
      attribute :color, :string
      attribute :weight, :string
      attribute :opacity, :string
      attribute :linestyle, :string
      attribute :joinstyle, :string
      attribute :endcap, :string
      attribute :on, :string

      xml do
        element "stroke"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "color", to: :color
        map_attribute "weight", to: :weight
        map_attribute "opacity", to: :opacity
        map_attribute "linestyle", to: :linestyle
        map_attribute "joinstyle", to: :joinstyle
        map_attribute "endcap", to: :endcap
        map_attribute "on", to: :on
      end
    end
  end
end
