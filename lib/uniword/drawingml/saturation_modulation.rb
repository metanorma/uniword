# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Saturation modulation
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:satMod>
    class SaturationModulation < Lutaml::Model::Serializable
      attribute :val, Integer

      xml do
        element 'satMod'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'val', to: :val
      end
    end
  end
end
