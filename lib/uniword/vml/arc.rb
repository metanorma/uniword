# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Vml
    # VML arc shape
    #
    # Element: <v:arc>
    class Arc < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :style, :string
      attribute :start_angle, :string
      attribute :end_angle, :string
      attribute :fillcolor, :string
      attribute :strokecolor, :string
      attribute :strokeweight, :string
      attribute :coordsize, :string
      attribute :coordorigin, :string
      attribute :filled, :string
      attribute :stroked, :string

      xml do
        element 'arc'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'id', to: :id
        map_attribute 'style', to: :style
        map_attribute 'startAngle', to: :start_angle
        map_attribute 'endAngle', to: :end_angle
        map_attribute 'fillcolor', to: :fillcolor
        map_attribute 'strokecolor', to: :strokecolor
        map_attribute 'strokeweight', to: :strokeweight
        map_attribute 'coordsize', to: :coordsize
        map_attribute 'coordorigin', to: :coordorigin
        map_attribute 'filled', to: :filled
        map_attribute 'stroked', to: :stroked
      end
    end
  end
end
