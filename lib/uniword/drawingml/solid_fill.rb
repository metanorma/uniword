# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Solid color fill
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:solidFill>
      class SolidFill < Lutaml::Model::Serializable


          xml do
            element 'solidFill'
            namespace Uniword::Ooxml::Namespaces::DrawingML

          end
      end
    end
end
