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
      attribute :scheme_clr, SchemeColor
      attribute :srgb_clr, SrgbColor

      xml do
        element 'innerShdw'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'blurRad', to: :blur_rad, render_nil: false
        map_attribute 'dist', to: :dist, render_nil: false
        map_attribute 'dir', to: :dir, render_nil: false
        map_element 'schemeClr', to: :scheme_clr, render_nil: false
        map_element 'srgbClr', to: :srgb_clr, render_nil: false
      end
    end
  end
end
