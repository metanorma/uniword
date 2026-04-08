# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Vml
    # VML shadow effect
    #
    # Element: <v:shadow>
    class Shadow < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :on, :string
      attribute :type, :string
      attribute :color, :string
      attribute :offset, :string
      attribute :opacity, :string
      attribute :origin, :string

      xml do
        element 'shadow'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'id', to: :id
        map_attribute 'on', to: :on
        map_attribute 'type', to: :type
        map_attribute 'color', to: :color
        map_attribute 'offset', to: :offset
        map_attribute 'opacity', to: :opacity
        map_attribute 'origin', to: :origin
      end
    end
  end
end
