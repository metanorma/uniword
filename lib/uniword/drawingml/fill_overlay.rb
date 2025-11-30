# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Fill overlay effect
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:fillOverlay>
      class FillOverlay < Lutaml::Model::Serializable
          attribute :blend, String

          xml do
            element 'fillOverlay'
            namespace Uniword::Ooxml::Namespaces::DrawingML

            map_attribute 'blend', to: :blend
          end
      end
    end
end
