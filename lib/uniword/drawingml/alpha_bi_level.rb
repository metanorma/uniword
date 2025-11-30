# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Alpha bi-level effect
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:alphaBiLevel>
    class AlphaBiLevel < Lutaml::Model::Serializable
      attribute :thresh, Integer

      xml do
        element 'alphaBiLevel'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'thresh', to: :thresh
      end
    end
  end
end
