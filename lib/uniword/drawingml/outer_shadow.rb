# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Outer shadow effect
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:outerShdw>
    class OuterShadow < Lutaml::Model::Serializable
      attribute :blur_rad, Integer
      attribute :dist, Integer
      attribute :dir, Integer
      attribute :algn, String

      xml do
        element 'outerShdw'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'blur-rad', to: :blur_rad
        map_attribute 'dist', to: :dist
        map_attribute 'dir', to: :dir
        map_attribute 'algn', to: :algn
      end
    end
  end
end
