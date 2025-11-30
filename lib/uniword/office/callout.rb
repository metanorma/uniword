# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Callout shape properties
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:callout>
    class Callout < Lutaml::Model::Serializable
      attribute true, :string
      attribute :type, :string
      attribute :gap, :string
      attribute :angle, :string
      attribute :dropauto, :string
      attribute :drop, :string
      attribute :distance, :string
      attribute :lengthspecified, :string

      xml do
        element 'callout'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'true', to: true
        map_attribute 'type', to: :type
        map_attribute 'gap', to: :gap
        map_attribute 'angle', to: :angle
        map_attribute 'dropauto', to: :dropauto
        map_attribute 'drop', to: :drop
        map_attribute 'distance', to: :distance
        map_attribute 'lengthspecified', to: :lengthspecified
      end
    end
  end
end
