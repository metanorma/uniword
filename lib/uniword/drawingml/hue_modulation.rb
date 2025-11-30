# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Hue modulation
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:hueMod>
    class HueModulation < Lutaml::Model::Serializable
      attribute :val, Integer

      xml do
        element 'hueMod'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'val', to: :val
      end
    end
  end
end
