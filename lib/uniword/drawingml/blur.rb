# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Blur effect
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:blur>
      class Blur < Lutaml::Model::Serializable
          attribute :rad, Integer
          attribute :grow, String

          xml do
            element 'blur'
            namespace Uniword::Ooxml::Namespaces::DrawingML

            map_attribute 'rad', to: :rad
            map_attribute 'grow', to: :grow
          end
      end
    end
end
