# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Custom dash pattern
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:custDash>
      class CustomDash < Lutaml::Model::Serializable
          attribute :dash_stops, DashStop, collection: true, default: -> { [] }

          xml do
            root 'custDash'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'ds', to: :dash_stops, render_nil: false
          end
      end
    end
  end
end
