# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Vml
    # VML document background
    #
    # Element: <v:background>
    class Background < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :fillcolor, :string
      attribute :strokecolor, :string
      attribute :strokeweight, :string
      attribute :filled, :string
      attribute :stroked, :string
      attribute :style, :string

      xml do
        element "background"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "id", to: :id
        map_attribute "fillcolor", to: :fillcolor
        map_attribute "strokecolor", to: :strokecolor
        map_attribute "strokeweight", to: :strokeweight
        map_attribute "filled", to: :filled
        map_attribute "stroked", to: :stroked
        map_attribute "style", to: :style
      end
    end
  end
end
