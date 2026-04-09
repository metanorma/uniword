# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Foreground color
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:fgClr>
    class ForegroundColor < Lutaml::Model::Serializable
      attribute :srgb_clr, SrgbColor
      attribute :scheme_clr, SchemeColor

      xml do
        element 'fgClr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'srgbClr', to: :srgb_clr, render_nil: false
        map_element 'schemeClr', to: :scheme_clr, render_nil: false
      end
    end
  end
end
