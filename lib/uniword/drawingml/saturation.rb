# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Saturation
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:sat>
    class Saturation < Lutaml::Model::Serializable
      attribute :val, Integer

      xml do
        element 'sat'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'val', to: :val
      end
    end
  end
end
