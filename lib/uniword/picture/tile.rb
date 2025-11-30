# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Picture
    # Tile properties for picture fill
    #
    # Generated from OOXML schema: picture.yml
    # Element: <pic:tile>
    class Tile < Lutaml::Model::Serializable
      attribute :tx, Integer
      attribute :ty, Integer
      attribute :sx, Integer
      attribute :sy, Integer
      attribute :algn, String

      xml do
        element 'tile'
        namespace Uniword::Ooxml::Namespaces::Picture

        map_attribute 'tx', to: :tx
        map_attribute 'ty', to: :ty
        map_attribute 'sx', to: :sx
        map_attribute 'sy', to: :sy
        map_attribute 'algn', to: :algn
      end
    end
  end
end
