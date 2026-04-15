# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Vml
    # VML curve shape
    #
    # Generated from OOXML schema: vml.yml
    # Element: <v:curve>
    class Curve < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :style, :string
      attribute :from, :string
      attribute :to, :string
      attribute :control1, :string
      attribute :control2, :string
      attribute :strokecolor, :string
      attribute :stroke, :string

      xml do
        element "curve"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "id", to: :id
        map_attribute "style", to: :style
        map_attribute "from", to: :from
        map_attribute "to", to: :to
        map_attribute "control1", to: :control1
        map_attribute "control2", to: :control2
        map_attribute "strokecolor", to: :strokecolor
        map_element "", to: :stroke, render_nil: false
      end
    end
  end
end
