# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Bi-level (black and white) effect
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:biLevel>
    class BiLevel < Lutaml::Model::Serializable
      attribute :thresh, Integer

      xml do
        element 'biLevel'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'thresh', to: :thresh
      end
    end
  end
end
