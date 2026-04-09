# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # 3D scene
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:scene3d>
    class Scene3D < Lutaml::Model::Serializable
      attribute :camera, Camera
      attribute :light_rig, LightRig

      xml do
        element 'scene3d'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'camera', to: :camera, render_nil: false
        map_element 'lightRig', to: :light_rig, render_nil: false
      end
    end
  end
end
