# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Solid color fill
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:solidFill>
    class SolidFill < Lutaml::Model::Serializable
      attribute :scheme_clr, SchemeColor
      attribute :srgb_clr, SrgbColor

      xml do
        element "solidFill"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element "schemeClr", to: :scheme_clr, render_nil: false
        map_element "srgbClr", to: :srgb_clr, render_nil: false
      end
    end
  end
end
