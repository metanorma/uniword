# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # 3D light rig
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:lightRig>
    class LightRig < Lutaml::Model::Serializable
      attribute :rig, :string
      attribute :dir, :string
      attribute :rot, Rotation

      xml do
        element "lightRig"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "rig", to: :rig, render_nil: false
        map_attribute "dir", to: :dir, render_nil: false
        map_element "rot", to: :rot, render_nil: false
      end
    end
  end
end
