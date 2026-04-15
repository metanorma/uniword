# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module VmlOffice
    # 3D skew effect for VML shapes
    #
    # Element: <o:skew>
    class VmlSkew < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :origin, :string
      attribute :type, :string
      attribute :angle, :string
      attribute :on, :string

      xml do
        element "skew"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "id", to: :id
        map_attribute "origin", to: :origin
        map_attribute "type", to: :type
        map_attribute "angle", to: :angle
        map_attribute "on", to: :on
      end
    end
  end
end
