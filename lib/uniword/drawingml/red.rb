# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Red component
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:red>
      class Red < Lutaml::Model::Serializable
          attribute :val, Integer

          xml do
            element 'red'
            namespace Uniword::Ooxml::Namespaces::DrawingML

            map_attribute 'val', to: :val
          end
      end
    end
end
