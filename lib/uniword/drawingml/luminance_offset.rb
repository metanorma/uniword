# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Luminance offset
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:lumOff>
    class LuminanceOffset < Lutaml::Model::Serializable
      attribute :val, Integer

      xml do
        element 'lumOff'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'val', to: :val
      end
    end
  end
end
