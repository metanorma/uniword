# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Soft edge effect
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:softEdge>
    class SoftEdge < Lutaml::Model::Serializable
      attribute :rad, :integer

      xml do
        element 'softEdge'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'rad', to: :rad
      end
    end
  end
end
