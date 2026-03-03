# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # 3D camera
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:camera>
    class Camera < Lutaml::Model::Serializable
      attribute :prst, :string
      attribute :rot, Rotation

      xml do
        element 'camera'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'prst', to: :prst, render_nil: false
        map_element 'rot', to: :rot, render_nil: false
      end
    end
  end
end
