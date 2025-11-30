# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Inner shadow effect
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:innerShdw>
    class InnerShadow < Lutaml::Model::Serializable
      attribute :blur_rad, :integer
      attribute :dist, :integer
      attribute :dir, :integer

      xml do
        element 'innerShdw'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'blur-rad', to: :blur_rad
        map_attribute 'dist', to: :dist
        map_attribute 'dir', to: :dir
      end
    end
  end
end
