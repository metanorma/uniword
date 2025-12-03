# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Gradient fill container
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:gradFill>
    class GradientFill < Lutaml::Model::Serializable
      attribute :rot_with_shape, :integer
      attribute :gs_lst, GradientStopList
      attribute :lin, LinearGradient
      attribute :path, PathGradient

      xml do
        element 'gradFill'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_attribute 'rotWithShape', to: :rot_with_shape, render_nil: false
        map_element 'gsLst', to: :gs_lst
        map_element 'lin', to: :lin, render_nil: false
        map_element 'path', to: :path, render_nil: false
      end
    end
  end
end
