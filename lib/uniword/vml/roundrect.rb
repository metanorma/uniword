# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Vml
    # VML rounded rectangle shape
    #
    # Element: <v:roundrect>
    class Roundrect < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :style, :string
      attribute :fillcolor, :string
      attribute :strokecolor, :string
      attribute :strokeweight, :string
      attribute :arcsize, :string
      attribute :coordsize, :string
      attribute :coordorigin, :string
      attribute :filled, :string
      attribute :stroked, :string

      xml do
        element 'roundrect'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'id', to: :id
        map_attribute 'style', to: :style
        map_attribute 'fillcolor', to: :fillcolor
        map_attribute 'strokecolor', to: :strokecolor
        map_attribute 'strokeweight', to: :strokeweight
        map_attribute 'arcsize', to: :arcsize
        map_attribute 'coordsize', to: :coordsize
        map_attribute 'coordorigin', to: :coordorigin
        map_attribute 'filled', to: :filled
        map_attribute 'stroked', to: :stroked
      end
    end
  end
end
