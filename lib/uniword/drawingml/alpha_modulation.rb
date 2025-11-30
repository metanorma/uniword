# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Alpha modulation
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:alphaMod>
      class AlphaModulation < Lutaml::Model::Serializable
          attribute :val, Integer

          xml do
            element 'alphaMod'
            namespace Uniword::Ooxml::Namespaces::DrawingML

            map_attribute 'val', to: :val
          end
      end
    end
end
