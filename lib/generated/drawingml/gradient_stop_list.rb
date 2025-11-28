# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Gradient stop list container
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:gsLst>
      class GradientStopList < Lutaml::Model::Serializable
          attribute :gradient_stops, GradientStop, collection: true, default: -> { [] }

          xml do
            root 'gsLst'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'gs', to: :gradient_stops, render_nil: false
          end
      end
    end
  end
end
