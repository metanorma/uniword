# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Glow effect
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:glow>
    class Glow < Lutaml::Model::Serializable
      attribute :rad, :integer
      attribute :srgb_clr, SrgbColor
      attribute :scheme_clr, SchemeColor

      xml do
        element 'glow'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'rad', to: :rad
        map_element 'srgbClr', to: :srgb_clr, render_nil: false
        map_element 'schemeClr', to: :scheme_clr, render_nil: false
      end
    end
  end
end
