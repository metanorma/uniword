# frozen_string_literal: true

require 'lutaml/model'

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
      attribute :dist, :integer

      xml do
        element 'reflection'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'blur-rad', to: :blur_rad
        map_attribute 'st-a', to: :st_a
        map_attribute 'end-a', to: :end_a
        map_attribute 'dist', to: :dist
      end
    end
  end
end
