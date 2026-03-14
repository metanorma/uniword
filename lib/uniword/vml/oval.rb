# frozen_string_literal: true

require 'lutaml/model'

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
      attribute :fill, :string
      attribute :stroke, :string

      xml do
        element 'oval'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'id', to: :id
        map_attribute 'style', to: :style
        map_attribute 'fillcolor', to: :fillcolor
        map_attribute 'strokecolor', to: :strokecolor
        map_attribute 'strokeweight', to: :strokeweight
        map_element '', to: :fill, render_nil: false
        map_element '', to: :stroke, render_nil: false
      end
    end
  end
end
