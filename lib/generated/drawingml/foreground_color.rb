# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Foreground color
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:fgClr>
      class ForegroundColor < Lutaml::Model::Serializable
          attribute :srgb_clr, SrgbColor
          attribute :scheme_clr, SchemeColor

          xml do
            root 'fgClr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'srgbClr', to: :srgb_clr, render_nil: false
            map_element 'schemeClr', to: :scheme_clr, render_nil: false
          end
      end
    end
  end
end
