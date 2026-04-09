# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Vml
    # VML fill properties
    #
    # Generated from OOXML schema: vml.yml
    # Element: <v:fill>
    class Fill < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :color, :string
      attribute :color2, :string
      attribute :opacity, :string
      attribute :angle, :string
      attribute :on, :string

      xml do
        element 'fill'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'type', to: :type
        map_attribute 'color', to: :color
        map_attribute 'color2', to: :color2
        map_attribute 'opacity', to: :opacity
        map_attribute 'angle', to: :angle
        map_attribute 'on', to: :on
      end
    end
  end
end
