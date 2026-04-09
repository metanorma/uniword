# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Saturation offset
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:satOff>
    class SaturationOffset < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element 'satOff'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'val', to: :val
      end
    end
  end
end
