# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Background color
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:bgClr>
      class BackgroundColor < Lutaml::Model::Serializable
          attribute :srgb_clr, SrgbColor
          attribute :scheme_clr, SchemeColor

          xml do
            element 'bgClr'
            namespace Uniword::Ooxml::Namespaces::DrawingML
            mixed_content

            map_element 'srgbClr', to: :srgb_clr, render_nil: false
            map_element 'schemeClr', to: :scheme_clr, render_nil: false
          end
      end
    end
end
