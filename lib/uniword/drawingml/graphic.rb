# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Graphic container
    # Contains GraphicData with the actual picture/shape
    class Graphic < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :graphic_data, GraphicData

      xml do
        root 'graphic'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'graphicData', to: :graphic_data, render_nil: false
      end
    end
  end
end
