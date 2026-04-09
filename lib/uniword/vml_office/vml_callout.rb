# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module VmlOffice
    # Callout shape for VML
    #
    # Element: <o:callout>
    class VmlCallout < Lutaml::Model::Serializable
      attribute :on, :string
      attribute :type, :string
      attribute :gap, :string
      attribute :angle, :string
      attribute :dropauto, :string
      attribute :lengthspecified, :string
      attribute :distancefromtext, :string
      attribute :drop, :string

      xml do
        element 'callout'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'on', to: :on
        map_attribute 'type', to: :type
        map_attribute 'gap', to: :gap
        map_attribute 'angle', to: :angle
        map_attribute 'dropauto', to: :dropauto
        map_attribute 'lengthspecified', to: :lengthspecified
        map_attribute 'distancefromtext', to: :distancefromtext
        map_attribute 'drop', to: :drop
      end
    end
  end
end
