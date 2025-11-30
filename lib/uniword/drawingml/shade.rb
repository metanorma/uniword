# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Shade
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:shade>
      class Shade < Lutaml::Model::Serializable
          attribute :val, Integer

          xml do
            element 'shade'
            namespace Uniword::Ooxml::Namespaces::DrawingML

            map_attribute 'val', to: :val
          end
      end
    end
end
