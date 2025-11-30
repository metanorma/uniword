# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Picture fill properties
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:blipFill>
      class BlipFill < Lutaml::Model::Serializable
          attribute :blip, Blip
          attribute :stretch, Stretch

          xml do
            element 'blipFill'
            namespace Uniword::Ooxml::Namespaces::DrawingML
            mixed_content

            map_element 'blip', to: :blip, render_nil: false
            map_element 'stretch', to: :stretch, render_nil: false
          end
      end
    end
end
