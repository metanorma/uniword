# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # SRGB color
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:srgbClr>
    class SrgbColor < Lutaml::Model::Serializable
      attribute :val, String

      xml do
        element 'srgbClr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'val', to: :val
      end
    end
  end
end
