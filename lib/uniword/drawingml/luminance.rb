# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Luminance
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:lum>
    class Luminance < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element 'lum'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'val', to: :val
      end
    end
  end
end
