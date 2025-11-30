# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Office
      # 3D extrusion effect for shapes
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:extrusion>
      class Extrusion < Lutaml::Model::Serializable
          attribute :true, String
          attribute :type, String
          attribute :render, String
          attribute :viewpointorigin, String
          attribute :viewpoint, String
          attribute :skewangle, String
          attribute :skewamt, String
          attribute :foredepth, String
          attribute :backdepth, String
          attribute :orientation, String
          attribute :orientationangle, String
          attribute :color, String
          attribute :rotationangle, String
          attribute :lightposition, String
          attribute :lightlevel, String
          attribute :lightharsh, String
          attribute :lightface, String

          xml do
            element 'extrusion'
            namespace Uniword::Ooxml::Namespaces::Office

            map_attribute 'true', to: :true
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
