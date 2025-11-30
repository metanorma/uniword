# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Lock object properties
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:lock>
    class Lock < Lutaml::Model::Serializable
      attribute :text, String
      attribute :shapetype, String
      attribute :rotation, String
      attribute :aspectratio, String
      attribute :position, String

      xml do
        element 'lock'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'text', to: :text
        map_attribute 'shapetype', to: :shapetype
        map_attribute 'rotation', to: :rotation
        map_attribute 'aspectratio', to: :aspectratio
        map_attribute 'position', to: :position
      end
    end
  end
end
