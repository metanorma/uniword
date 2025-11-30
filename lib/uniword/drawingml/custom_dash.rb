# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Custom dash pattern
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:custDash>
      class CustomDash < Lutaml::Model::Serializable
          attribute :dash_stops, DashStop, collection: true, default: -> { [] }

          xml do
            element 'custDash'
            namespace Uniword::Ooxml::Namespaces::DrawingML
            mixed_content

            map_element 'ds', to: :dash_stops, render_nil: false
          end
      end
    end
end
