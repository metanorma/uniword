# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Reflection effect
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:reflection>
    class Reflection < Lutaml::Model::Serializable
      attribute :blur_rad, :integer
      attribute :st_a, :integer
      attribute :end_a, :integer
      attribute :end_pos, :integer
      attribute :dist, :integer
      attribute :dir, :integer
      attribute :sy, :integer
      attribute :rot_with_shape, :integer

      xml do
        element "reflection"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "blurRad", to: :blur_rad, render_nil: false
        map_attribute "stA", to: :st_a, render_nil: false
        map_attribute "endA", to: :end_a, render_nil: false
        map_attribute "endPos", to: :end_pos, render_nil: false
        map_attribute "dist", to: :dist, render_nil: false
        map_attribute "dir", to: :dir, render_nil: false
        map_attribute "sy", to: :sy, render_nil: false
        map_attribute "rotWithShape", to: :rot_with_shape, render_nil: false
      end
    end
  end
end
