# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'extrusion'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :true
            map_attribute 'true', to: :type
            map_attribute 'true', to: :render
            map_attribute 'true', to: :viewpointorigin
            map_attribute 'true', to: :viewpoint
            map_attribute 'true', to: :skewangle
            map_attribute 'true', to: :skewamt
            map_attribute 'true', to: :foredepth
            map_attribute 'true', to: :backdepth
            map_attribute 'true', to: :orientation
            map_attribute 'true', to: :orientationangle
            map_attribute 'true', to: :color
            map_attribute 'true', to: :rotationangle
            map_attribute 'true', to: :lightposition
            map_attribute 'true', to: :lightlevel
            map_attribute 'true', to: :lightharsh
            map_attribute 'true', to: :lightface
          end
      end
    end
  end
end
