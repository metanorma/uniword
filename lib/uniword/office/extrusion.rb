# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # 3D extrusion effect for shapes
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:extrusion>
    class Extrusion < Lutaml::Model::Serializable
      attribute true, :string
      attribute :type, :string
      attribute :render, :string
      attribute :viewpointorigin, :string
      attribute :viewpoint, :string
      attribute :skewangle, :string
      attribute :skewamt, :string
      attribute :foredepth, :string
      attribute :backdepth, :string
      attribute :orientation, :string
      attribute :orientationangle, :string
      attribute :color, :string
      attribute :rotationangle, :string
      attribute :lightposition, :string
      attribute :lightlevel, :string
      attribute :lightharsh, :string
      attribute :lightface, :string

      xml do
        element 'extrusion'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'true', to: true
        map_attribute 'type', to: :type
        map_attribute 'render', to: :render
        map_attribute 'viewpointorigin', to: :viewpointorigin
        map_attribute 'viewpoint', to: :viewpoint
        map_attribute 'skewangle', to: :skewangle
        map_attribute 'skewamt', to: :skewamt
        map_attribute 'foredepth', to: :foredepth
        map_attribute 'backdepth', to: :backdepth
        map_attribute 'orientation', to: :orientation
        map_attribute 'orientationangle', to: :orientationangle
        map_attribute 'color', to: :color
        map_attribute 'rotationangle', to: :rotationangle
        map_attribute 'lightposition', to: :lightposition
        map_attribute 'lightlevel', to: :lightlevel
        map_attribute 'lightharsh', to: :lightharsh
        map_attribute 'lightface', to: :lightface
      end
    end
  end
end
