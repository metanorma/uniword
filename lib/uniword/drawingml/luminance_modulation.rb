# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Luminance modulation
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:lumMod>
    class LuminanceModulation < Lutaml::Model::Serializable
      attribute :val, Integer

      xml do
        element 'lumMod'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'val', to: :val
      end
    end
  end
end
