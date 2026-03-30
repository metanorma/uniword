# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Graphic Data container
    # Contains URI and picture reference
    class GraphicData < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :uri, :string
      attribute :picture, Uniword::Picture::Picture
      attribute :chart, Uniword::Chart::ChartReference

      xml do
        root 'graphicData'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'uri', to: :uri, render_nil: false
        map_element 'pic', to: :picture, render_nil: false
        map_element 'chart', to: :chart, render_nil: false
      end
    end
  end
end
