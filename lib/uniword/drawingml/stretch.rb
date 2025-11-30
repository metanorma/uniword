# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Stretch fill to shape bounds
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:stretch>
      class Stretch < Lutaml::Model::Serializable


          xml do
            element 'stretch'
            namespace Uniword::Ooxml::Namespaces::DrawingML

          end
      end
    end
end
