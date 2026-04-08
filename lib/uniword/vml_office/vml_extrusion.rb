# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module VmlOffice
    # 3D extrusion effect for VML shapes
    #
    # Element: <o:extrusion>
    class VmlExtrusion < Lutaml::Model::Serializable
      attribute :on, :string
      attribute :type, :string
      attribute :vieworigin, :string
      attribute :viewpoint, :string
      attribute :skewangle, :string
      attribute :backdepth, :string
      attribute :foredepth, :string
      attribute :lightposition, :string
      attribute :lightpositionadvanced, :string
      attribute :lightharsh, :string
      attribute :lightharshadv, :string
      attribute :shadowmode, :string

      xml do
        element 'extrusion'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'on', to: :on
        map_attribute 'type', to: :type
        map_attribute 'vieworigin', to: :vieworigin
        map_attribute 'viewpoint', to: :viewpoint
        map_attribute 'skewangle', to: :skewangle
        map_attribute 'backdepth', to: :backdepth
        map_attribute 'foredepth', to: :foredepth
        map_attribute 'lightposition', to: :lightposition
        map_attribute 'lightpositionadvanced', to: :lightpositionadvanced
        map_attribute 'lightharsh', to: :lightharsh
        map_attribute 'lightharshadv', to: :lightharshadv
        map_attribute 'shadowmode', to: :shadowmode
      end
    end
  end
end
